-- Filename: lua/plugins/lsp.lua
-- This is a complete and corrected configuration for your LSP setup.

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- These plugins automatically manage LSP server installations
      "williamboman/mason-lspconfig.nvim",
      "williamboman/mason.nvim",
    },
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              -- 1. Enable the server's built-in schema store for all other files.
              schemaStore = {
                enable = true,
              },

              schemas = {
                -- 2. Your manual override for your specific file patterns.
                --    This takes precedence.
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.0-standalone-strict/all.json"] = {
                  "*.k8s.yaml",
                  "deployment.yaml",
                  "k8s/*",
                  "kube/*",
                },
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose.yaml",
                ["kubernetes"] = "",
              },
            },
          },
        },
      },
    },
  },
}
