{ config, lib, pkgs, ... }:
let
  customPlugins = {
    darcula = pkgs.vimUtils.buildVimPlugin {
        pname = "darcula";
        version = "faf8dbab27bee0f27e4f1c3ca7e9695af9b1242b";
        src = pkgs.fetchFromGitHub {
          owner = "doums";
          repo = "darcula";
          rev = "faf8dbab27bee0f27e4f1c3ca7e9695af9b1242b";
          sha256 = "sha256-Gn+lmlYxSIr91Bg3fth2GAQou2Nd1UjrLkIFbBYlmF8=";
        };
    };
    vim-slim = pkgs.vimUtils.buildVimPlugin {
      pname = "vim-slim";
      version = "a0a57f75f20a03d5fa798484743e98f4af623926";
      src = pkgs.fetchFromGitHub {
        owner = "slim-template";
        repo = "vim-slim";
        rev = "a0a57f75f20a03d5fa798484743e98f4af623926";
        sha256 = "sha256-mPv0tiggGExEZNshDlHtT4ipv/5Q0ahkcVw4irJ8l3o=";
      };
    };
  };
  base = home: {
    home.sessionVariables = { EDITOR = "nvim"; };
    programs.neovim = {
      enable = true;
      vimAlias = true;
      extraPackages = [ pkgs.xclip ];
      extraConfig = ''
        set nocompatible
        filetype off	

        autocmd FileType age call Nix()
        autocmd FileType mail call Text()
        autocmd FileType markdown call Text()
        autocmd FileType tex call Text()
        autocmd FileType gitcommit call Text()
        autocmd FileType mail set colorcolumn=72

        function Text()
          set spell spelllang=en_us,nl
          "set formatoptions+=a " Automatic wrapping & unwrapping
          "set formatoptions+=1 " Prefer to wrap before single character words
          set formatoptions+=n " Keep list alignment
        endfunction


        function! s:goyo_enter()
          let b:quitting = 0
          let b:quitting_bang = 0
          set linebreak
          set wrap
          autocmd QuitPre <buffer> let b:quitting = 1
          cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
        endfunction

        function! s:goyo_leave()
          " Quit Vim if this is the only remaining buffer
          if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
            if b:quitting_bang
              qa!
            else
              qa
            endif
          endif
        endfunction

        autocmd! User GoyoEnter call <SID>goyo_enter()
        autocmd! User GoyoLeave call <SID>goyo_leave()

        function Nix()
        set filetype=nix
        endfunction

        noremap J <C-d>
        noremap K <C-u>

        set undofile
        set undodir=~/.vimundo/

        syntax enable
        set background=light
        colorscheme darcula
        set number
        set showcmd
        set autoread
        set scrolloff=8
        set expandtab
        set tabstop=4
        set shiftwidth=4
        set colorcolumn=80

        " Allow project-specific .vimrc files, but disable unsafe commands
        set exrc
        set secure

        " display tabs with a leading \cdot
        " trailing whitespace looks like \cdot
        set list
        set listchars=tab:·\ ,trail:·

        " Write as root
        cmap w!! w !sudo tee > /dev/null %

        " Write by pressing escape a lot
        map <Esc><Esc> :w<CR>

        " Unhighlight highlighted stuff
        map <C-s> :noh<CR>

        if has('nvim')
        " Command substitution: see 'live' what will be changed
        set inccommand=split
        endif

        set clipboard=unnamedplus

        set hidden

        filetype plugin indent on

        autocmd FileType javascript call TwoSpaces()
        autocmd FileType less call TwoSpaces()
        autocmd FileType css call TwoSpaces()
        autocmd FileType scss call TwoSpaces()
        autocmd FileType html call TwoSpaces()
        autocmd FileType ruby call TwoSpaces()
        autocmd FileType yaml call TwoSpaces()
        autocmd FileType eruby call TwoSpaces()
        autocmd FileType haskell call TwoSpaces()
        autocmd FileType json call TwoSpaces()
        autocmd FileType crystal call TwoSpaces()
        autocmd FileType pug call TwoSpaces()
        autocmd FileType typescript call TwoSpaces()
        autocmd FileType nix call TwoSpaces()

        autocmd FileType ansible set syntax=yaml

        function TwoSpaces()
          setlocal tabstop=2
          setlocal shiftwidth=2
          setlocal softtabstop=2
        endfunction

        let g:goyo_height = '100%'
        autocmd vimenter *.md Goyo

        let g:vim_markdown_folding_disabled = 1
        let g:vim_markdown_no_default_key_mappings = 1
        set conceallevel=3
      '';

    plugins = with pkgs.vimPlugins // customPlugins; [
        darcula
        vim-beancount
        vim-nix
        editorconfig-vim
        goyo-vim
        vim-markdown
        vim-slim
      ];
    };
  };
in
{
  options.custom.neovim = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
  };

  config = lib.mkIf config.custom.neovim.enable {
    home-manager.users.${config.custom.user} = { ... }: (base "/home/${config.custom.user}");
    home-manager.users.root = { ... }: (base "/root");
  };
}
