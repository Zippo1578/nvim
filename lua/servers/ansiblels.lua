-- ================================================================================================
-- TITLE : ansiblels (Ansible Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/ansible/ansible-language-server
-- ================================================================================================

--- @param capabilities table LSP client capabilities
--- @return nil
return function(capabilities)
    vim.lsp.config('ansiblels', {
        capabilities = capabilities,
        filetypes = { "yaml.ansible", "ansible" },
        settings = {
            ansible = {
                ansible = {
                    path = "ansible",
                },
                executionEnvironment = {
                    enabled = false,
                },
                validation = {
                    enabled = true,
                    lint = {
                        enabled = true,
                        path = "ansible-lint",
                    },
                },
            },
        },
    })
end
