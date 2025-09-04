{ inputs, pkgs, ... }: {
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      # keep your own UI/UX prefs; tweak as you like
      vimAlias = true;
      viAlias = true;
      withNodeJs = true;
      lineNumberMode = "relNumber";
      enableLuaLoader = true;
      preventJunkFiles = true;

      options = {
        tabstop = 4;
        shiftwidth = 2;
        wrap = false;
      };

      clipboard = {
        enable = true;
        registers = "unnamedplus";
        providers.wl-copy.enable = true;
        providers.xsel.enable = true;
      };

      diagnostics.enable = true;

      # Make Lazy/LazyVim available at runtime (plus your direct deps)
      extraPlugins = with pkgs.vimPlugins; [
        lazy-nvim
        LazyVim

        # direct plugins you declared (names follow nixpkgs)
        vim-dotenv
        SchemaStore-nvim
        nvim-treesitter
        mason-tool-installer-nvim
        nvim-lspconfig
        mason-nvim
        mason-lspconfig-nvim
        vim-just
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
        cmp-sql
        crates-nvim
        rustaceanvim
        nvim-cmp
      ];
    };
  };

  # ---- Your exact Lua config & plugin specs ----
  xdg.configFile."nvim/init.lua".text = ''
    -- bootstrap lazy.nvim, LazyVim and your plugins
    require("config.lazy")
  '';

  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    require("lazy").setup({
      spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        { import = "plugins" },
        { import = "plugins.rust" },
      },
      defaults = {
        lazy = false,
        version = false,
      },
      install = { colorscheme = { "tokyonight", "habamax" } },
      checker = { enabled = true, notify = false },
      performance = {
        rtp = {
          disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
        },
      },
    })

    vim.opt.exrc = true
    vim.opt.secure = true

    local lspconfig = require("lspconfig")
    lspconfig.postgres_lsp.setup({
      settings = { ["postgres-language-server"] = {} },
      filetypes = { "sql", "pgsql", "postgres", "sql.dockerfile" },
    })

    vim.diagnostic.config({
      float = { focusable = true, source = true, border = "rounded" },
    })
  '';

  # ----- plugins/ -----

  xdg.configFile."nvim/lua/plugins/vim-dotenv.lua".text = ''
    return {
      {
        "tpope/vim-dotenv",
        config = function()
          vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
            group = vim.api.nvim_create_augroup("DotenvLoader", { clear = true }),
            pattern = {
              "*.sql","*.go","*.js","*.ts","*.rs","*.py","*.rb","*.php",
              "docker-compose.yml","Dockerfile",
            },
            callback = function()
              local current_file = vim.api.nvim_buf_get_name(0)
              if current_file == "" then return end
              local current_dir = vim.fn.fnamemodify(current_file, ":p:h")
              local env_file_path = vim.fn.findfile(".env", current_dir .. ";")
              if env_file_path ~= "" then
                local ok, err = pcall(vim.cmd, "Dotenv " .. env_file_path)
                if not ok then vim.notify("Failed to load .env: " .. err, vim.log.levels.ERROR) end
              end
            end,
          })
        end,
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/schemastore.lua".text = ''
    return {
      "b0o/SchemaStore.nvim",
      lazy = true,
      version = false,
    }
  '';

  xdg.configFile."nvim/lua/plugins/nvim-treesitter.lua".text = ''
    return {
      "nvim-treesitter/nvim-treesitter",
      opts = { ensure_installed = { "rust", "ron" } },
    }
  '';

  xdg.configFile."nvim/lua/plugins/mason-tool-installer.lua".text = ''
    return {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      config = function()
        require("mason-tool-installer").setup({
          ensure_installed = {
            "dockerfile-language-server","eslint-lsp","eslint_d","hadolint","kube-linter",
            "lua-language-server","prettier","shfmt","stylua","tailwindcss-language-server",
            "typescript-language-server","yamlls","just-lsp",
          },
          run_on_start = true,
          auto_update = true,
        })
      end,
    }
  '';

  xdg.configFile."nvim/lua/plugins/lsp.lua".text = ''
    return {
      {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim", "williamboman/mason.nvim" },
        opts = {
          servers = {
            yamlls = {
              settings = {
                yaml = {
                  schemaStore = { enable = true },
                  schemas = {
                    ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.0-standalone-strict/all.json"] =
                      { "*.k8s.yaml","deployment.yaml","k8s/*","kube/*" },
                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] =
                      "docker-compose.yaml",
                    ["kubernetes"] = "",
                  },
                },
              },
            },
          },
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/just.lua".text = ''
    return {
      "NoahTheDuke/vim-just",
      ft = { "just" },
    }
  '';

  xdg.configFile."nvim/lua/plugins/dadbod.lua".text = ''
    return {
      { "tpope/vim-dadbod" },
      {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = { "tpope/vim-dadbod" },
        cmd = { "DBUI","DBUIToggle","DBUIAddConnection","DBUIFindBuffer" },
        init = function()
          vim.g.db_ui_use_nerd_fonts = 1
          vim.g.db_ui_winwidth = 40
          vim.g.db_ui_notification_width = 39
        end,
      },
      {
        "kristijanhusak/vim-dadbod-completion",
        dependencies = { "tpope/vim-dadbod", "hrsh7th/nvim-cmp" },
        ft = { "sql","mysql","plsql" },
        config = function()
          vim.g.db_completion_enabled = 1
          vim.api.nvim_create_autocmd("FileType", {
            pattern = { "sql","mysql","plsql" },
            callback = function()
              vim.bo.omnifunc = "vim_dadbod_completion#omni"
              print("SQL FileType autocmd fired - sources configured")
            end,
          })
        end,
      },
      { "ray-x/cmp-sql", dependencies = { "hrsh7th/nvim-cmp" }, ft = { "sql","mysql","plsql" } },
    }
  '';

  xdg.configFile."nvim/lua/plugins/crates.lua".text = ''
    return {
      "Saecki/crates.nvim",
      event = { "BufRead Cargo.toml" },
      opts = {
        completion = { crates = { enabled = true } },
        lsp = { enabled = true, actions = true, completion = true, hover = true },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/rust/rustaceanvim.lua".text = ''
    return {
      "mrcjkb/rustaceanvim",
      version = vim.fn.has("nvim-0.10.0") == 0 and "^4" or false,
      ft = { "rust" },
      opts = {
        server = {
          on_attach = function(_, bufnr)
            if vim.bo[bufnr].filetype == "rust" then
              vim.keymap.set("n","<leader>cR", function() vim.cmd.RustLsp("codeAction") end, { desc="Code Action", buffer=bufnr })
              vim.keymap.set("n","<leader>dr", function() vim.cmd.RustLsp("debuggables") end, { desc="Rust Debuggables", buffer=bufnr })
            end
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true, loadOutDirsFromCheck = true, buildScripts = { enable = true } },
              completion = { autoimport = { enable = true } },
              imports = { granularity = { group = "module" }, prefix = "self" },
              checkOnSave = { command = "check" },
              diagnostics = { enable = true },
              procMacro = { enable = true, ignored = { ["napi-derive"] = { "napi" }, ["async-recursion"] = { "async_recursion" } } },
              files = { excludeDirs = { ".direnv",".git",".github",".gitlab","bin","node_modules","target","venv",".venv" } },
            },
          },
        },
      },
      config = function(_, opts)
        if vim.fn.executable("rust-analyzer") == 0 then
          LazyVim.error("**rust-analyzer** not found in PATH, please install it.\nhttps://rust-analyzer.github.io/", { title = "rustaceanvim" })
          return
        end
        if LazyVim.has("mason.nvim") then
          local mason_registry = require("mason-registry")
          if mason_registry.is_installed("codelldb") then
            local package_path = mason_registry.get_package("codelldb"):get_install_path()
            local codelldb = package_path .. "/extension/adapter/codelldb"
            local library_path = package_path .. "/extension/lldb/lib/liblldb.dylib"
            local uname = io.popen("uname"):read("*l")
            if uname == "Linux" then library_path = package_path .. "/extension/lldb/lib/liblldb.so" end
            opts.dap = { adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library_path) }
          end
        end
        vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
      end,
    }
  '';
}
