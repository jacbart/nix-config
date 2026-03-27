_: {
  programs.bottom = {
    enable = true;
    settings = {
      styles = {
        theme = "gruvbox";
      };
      colors = {
        high_battery_color = "green";
        medium_battery_color = "yellow";
        low_battery_color = "red";
      };
      disk_filter = {
        is_list_ignored = true;
        list = [ "/dev/loop" ];
        regex = true;
        case_sensitive = false;
        whole_word = false;
      };
      flags = {
        dot_marker = false;
        enable_gpu_memory = true;
        group_processes = true;
        hide_table_gap = true;
        mem_as_value = true;
        tree = true;
        avg_cpu = true;
        temperature_type = "c";
        battery = true;
      };
      layout = {
        row = [
          {
            child = [
              {
                type = "cpu";
              }
              {
                type = "batt";
              }
            ];
          }
          {
            ratio = 2;
            child = [
              {
                ratio = 4;
                type = "mem";
              }
              {
                ratio = 3;
                child = [
                  { type = "temp"; }
                  { type = "disk"; }
                ];
              }
            ];
          }
          {
            child = [
              { type = "net"; }
              { type = "proc"; }
            ];
          }
        ];
      };
    };
  };
}
