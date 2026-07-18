#!/usr/bin/env python3
"""wa - natural language Wolfram Language chat via local LLM + woxi.

Starts a local llama-server (Qwen3-4B) on demand, translates natural
language queries into Wolfram Language, evaluates them with woxi, and
displays results inline. Graphics are shown via the kitty graphics
protocol with a file-path fallback.
"""

import sys
import os
import json
import time
import re
import socket
import base64
import subprocess
import tempfile
import signal
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

SERVER_PORT = 8899
SERVER_URL = f"http://127.0.0.1:{SERVER_PORT}"
MODEL = "unsloth/Qwen3-4B-GGUF:Q5_K_M"
CTX_SIZE = 4096
MAX_RETRIES = 2
TEMPERATURE = 0.1
MAX_TOKENS = 512
WOXI_TIMEOUT = 30
SERVER_STARTUP_TIMEOUT = 180
PID_FILE = os.path.join(tempfile.gettempdir(), "wa_llama_server.pid")
LOG_FILE = os.path.join(tempfile.gettempdir(), "wa_llama_server.log")

SYSTEM_PROMPT = """\
/no_think
You are a Wolfram Language expert. Translate natural language queries into \
a single Wolfram Language expression. Output ONLY the expression — no \
explanation, no markdown, no code fences, no commentary. Use proper Wolfram \
Language syntax: Sin[x] not sin(x), Pi not pi, == for equality, {} for lists.

Examples:
"what is 2 plus 2" -> 2 + 2
"derivative of sin of x" -> D[Sin[x], x]
"factorial of 10" -> 10!
"solve x squared minus 1 equals 0" -> Solve[x^2 - 1 == 0, x]
"plot sine of x from 0 to pi" -> Plot[Sin[x], {x, 0, Pi}]
"eigenvalues of matrix {{1,2},{3,4}}" -> Eigenvalues[{{1, 2}, {3, 4}}]
"simplify x squared minus 1 over x minus 1" -> Simplify[(x^2 - 1)/(x - 1)]
"10th prime number" -> Prime[10]
"integrate x squared from 0 to 1" -> Integrate[x^2, {x, 0, 1}]
"expand (x+1)^5" -> Expand[(x + 1)^5]
"first 10 fibonacci numbers" -> Table[Fibonacci[n], {n, 1, 10}]
"mean of 1,2,3,4,5" -> Mean[{1, 2, 3, 4, 5}]
"determinant of {{1,2},{3,4}}" -> Det[{{1, 2}, {3, 4}}]
"limit of sin(x)/x as x approaches 0" -> Limit[Sin[x]/x, x -> 0]
"taylor series of e^x around 0 to order 5" -> Series[Exp[x], {x, 0, 5}]
"sum of first 100 integers" -> Sum[i, {i, 1, 100}]
"plot cos and sin from 0 to 2pi" -> Plot[{Cos[x], Sin[x]}, {x, 0, 2*Pi}]
"3x3 identity matrix" -> IdentityMatrix[3]
"reverse the list {1,2,3,4,5}" -> Reverse[{1, 2, 3, 4, 5}]
"histogram of random numbers" -> Histogram[RandomReal[{0, 1}, 100]]
"""


def is_server_running():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1)
        s.connect(("127.0.0.1", SERVER_PORT))
        s.close()
        return True
    except (socket.error, ConnectionRefusedError, OSError):
        return False


def start_server():
    if is_server_running():
        return True

    log_fh = open(LOG_FILE, "w")
    proc = subprocess.Popen(
        [
            "llama-server",
            "-hf", MODEL,
            "--port", str(SERVER_PORT),
            "-c", str(CTX_SIZE),
            "-ngl", "99",
        ],
        stdout=log_fh,
        stderr=subprocess.STDOUT,
        stdin=subprocess.DEVNULL,
        start_new_session=True,
    )

    with open(PID_FILE, "w") as f:
        f.write(str(proc.pid))

    return wait_for_server()


def wait_for_server():
    deadline = time.time() + SERVER_STARTUP_TIMEOUT
    while time.time() < deadline:
        if is_server_running():
            try:
                req = Request(f"{SERVER_URL}/health")
                with urlopen(req, timeout=2) as resp:
                    if resp.status == 200:
                        return True
            except (URLError, HTTPError, OSError):
                pass
        time.sleep(1)
    return False


def stop_server():
    if os.path.exists(PID_FILE):
        with open(PID_FILE) as f:
            pid = int(f.read().strip())
        try:
            os.kill(pid, signal.SIGTERM)
            print("Server stopped.")
        except ProcessLookupError:
            print("Server was not running.")
        os.remove(PID_FILE)
    else:
        subprocess.run(
            ["pkill", "-f", f"llama-server.*{SERVER_PORT}"],
            capture_output=True,
        )
        print("Server stopped.")


def llm_chat(messages):
    body = json.dumps(
        {
            "model": "default",
            "messages": messages,
            "temperature": TEMPERATURE,
            "max_tokens": MAX_TOKENS,
        }
    ).encode()

    req = Request(
        f"{SERVER_URL}/v1/chat/completions",
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    with urlopen(req, timeout=120) as resp:
        result = json.loads(resp.read())
        return result["choices"][0]["message"]["content"]


def extract_wl_code(text):
    text = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL)
    text = re.sub(r"```(?:wolfram|mathematica|wl)?\s*\n(.*?)```", r"\1", text, flags=re.DOTALL)
    text = text.replace("`", "")
    text = text.strip()
    lines = text.splitlines()
    code_lines = [
        l for l in lines
        if l.strip()
        and not l.strip().startswith("#")
        and not l.strip().lower().startswith(("here ", "the ", "this ", "let ", "sure", "i "))
    ]
    if code_lines:
        return "\n".join(code_lines).strip()
    return text


def run_woxi(code):
    try:
        result = subprocess.run(
            ["woxi", "eval", "-"],
            input=code,
            capture_output=True,
            text=True,
            timeout=WOXI_TIMEOUT,
        )
        if result.returncode != 0:
            err = result.stderr.strip() or result.stdout.strip()
            return None, err if err else "evaluation error"
        return result.stdout.strip(), None
    except subprocess.TimeoutExpired:
        return None, "timeout"


def is_graphics_output(output):
    return (
        output.startswith("-")
        and output.endswith("-")
        and ("Graphics" in output or "Image" in output)
    )


def display_graphics(code):
    png_path = tempfile.mktemp(suffix=".png", prefix="wa_plot_")
    export_code = f'result = ({code}); Export["{png_path}", result]'
    try:
        subprocess.run(
            ["woxi", "eval", "-"],
            input=export_code,
            capture_output=True,
            text=True,
            timeout=WOXI_TIMEOUT,
        )
    except subprocess.TimeoutExpired:
        pass

    if os.path.exists(png_path) and os.path.getsize(png_path) > 0:
        display_image_kitty(png_path)
        print(f"  saved: {png_path}")
    else:
        print("  failed to export image")


def display_image_kitty(path):
    with open(path, "rb") as f:
        data = base64.b64encode(f.read()).decode("ascii")

    chunk_size = 4096
    chunks = [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]

    for i, chunk in enumerate(chunks):
        if i == 0 and len(chunks) == 1:
            esc = f"\033_Ga=T,t=100;{chunk}\033\\"
        elif i == 0:
            esc = f"\033_Ga=T,t=100,m=1;{chunk}\033\\"
        elif i == len(chunks) - 1:
            esc = f"\033_Gm=0;{chunk}\033\\"
        else:
            esc = f"\033_Gm=1;{chunk}\033\\"

        if "TMUX" in os.environ:
            esc = esc.replace("\033", "\033\033")
            esc = f"\033P{esc}\033\\"

        sys.stdout.buffer.write(esc.encode("ascii"))
        sys.stdout.buffer.flush()


def process_query(query, messages):
    messages.append({"role": "user", "content": query})

    for attempt in range(MAX_RETRIES + 1):
        try:
            response = llm_chat(messages)
        except Exception as e:
            print(f"  LLM error: {e}")
            return

        code = extract_wl_code(response)
        if not code:
            print(f"  could not extract code from: {response[:200]}")
            return

        print(f"  WL: {code}")

        output, error = run_woxi(code)

        if error:
            if attempt < MAX_RETRIES:
                print(f"  error: {error[:200]}")
                print("  retrying...")
                messages.append({"role": "assistant", "content": code})
                messages.append(
                    {"role": "user", "content": f"Error: {error[:300]}. Fix and output ONLY the corrected expression."}
                )
                continue
            print(f"  error: {error[:200]}")
            messages.append({"role": "assistant", "content": code})
            return

        if output and is_graphics_output(output):
            display_graphics(code)
        elif output:
            print(f"  = {output}")
        else:
            print("  (no output)")

        messages.append({"role": "assistant", "content": code})
        if output and not is_graphics_output(output):
            truncated = output[:500] + ("..." if len(output) > 500 else "")
            messages.append({"role": "system", "content": f"Result: {truncated}"})
        return


def interactive_mode():
    print("wa - natural language Wolfram Language chat")
    print("type 'exit' to quit, 'wa --stop' to kill the server\n")
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    while True:
        try:
            query = input("» ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if not query:
            continue
        if query.lower() in ("exit", "quit", "q"):
            break
        process_query(query, messages)
        print()


def one_shot_mode(query):
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    process_query(query, messages)


def main():
    args = sys.argv[1:]
    if args:
        if args[0] == "--stop":
            stop_server()
            return
        if args[0] == "--status":
            print("running" if is_server_running() else "not running")
            return
        if args[0] in ("-h", "--help"):
            print("wa - natural language Wolfram Language chat")
            print()
            print("usage: wa [query]")
            print("  wa                  interactive REPL")
            print("  wa <query>          one-shot query")
            print("  wa --stop           stop llama-server")
            print("  wa --status         check server status")
            return

    if not is_server_running():
        print("starting llama-server (first run downloads ~2.8GB model)...")
        if not start_server():
            print(f"failed to start server. check log: {LOG_FILE}")
            return
        print("server ready.\n")

    query = " ".join(args) if args else None
    if query:
        one_shot_mode(query)
    else:
        interactive_mode()


if __name__ == "__main__":
    main()
