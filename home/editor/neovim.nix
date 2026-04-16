{ config, pkgs, lib, dotfilesPath, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraWrapperArgs = [
      "--suffix" "LD_LIBRARY_PATH" ":" "${pkgs.sqlite.out}/lib"
    ];
  };

  # Deploy LazyVim config via symlink so lazy.nvim can write to the directory
  # Use mkOutOfStoreSymlink so the config stays mutable (LazyVim needs to write lock files etc.)
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${dotfilesPath}/raw/nvim";
}
