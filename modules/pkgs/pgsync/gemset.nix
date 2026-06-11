{
  bigdecimal = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g9zi8c4i7g8zz0c3hxrw6mblrjvgn7akys60clb9si7c1k1gljk";
      type = "gem";
    };
    version = "4.1.2";
  };
  parallel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0w697335hi5dk5ay9kyn53399sy87y8v0y6ij93m5wmshhadxrik";
      type = "gem";
    };
    version = "1.28.0";
  };
  pg = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16caca7lcz5pwl82snarqrayjj9j7abmxqw92267blhk7rbd120k";
      type = "gem";
    };
    version = "1.6.3";
  };
  pgsync = {
    dependencies = ["bigdecimal" "parallel" "pg" "slop" "tty-spinner"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0s42xggxk8jmf8rshrb2b0harv1k3crw7x12b6wbcyzwdkajx945";
      type = "gem";
    };
    version = "0.8.1";
  };
  slop = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1iyrjskgxyn8i1679qwkzns85p909aq77cgx2m4fs5ygzysj4hw4";
      type = "gem";
    };
    version = "4.10.1";
  };
  tty-cursor = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j5zw041jgkmn605ya1zc151bxgxl6v192v2i26qhxx7ws2l2lvr";
      type = "gem";
    };
    version = "0.7.1";
  };
  tty-spinner = {
    dependencies = ["tty-cursor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hh5awmijnzw9flmh5ak610x1d00xiqagxa5mbr63ysggc26y0qf";
      type = "gem";
    };
    version = "0.9.3";
  };
}
