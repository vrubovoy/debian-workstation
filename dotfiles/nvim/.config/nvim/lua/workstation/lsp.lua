-- =============================================================================
-- Neovim — language servers
-- =============================================================================
--
-- No server is enabled globally. A project lists its own in .nvim.lua at its
-- root, with the names from :help lspconfig-all:
--
--     require("workstation.lsp").enable({ "clangd", "basedpyright" })
--
-- A server that is not on PATH is installed through Mason first. Neovim asks
-- once whether to trust a new or changed .nvim.lua.
--
-- Path:  ~/.config/nvim/lua/workstation/lsp.lua

local M = {}

local function on_path(server)
    local cmd = (vim.lsp.config[server] or {}).cmd
    return type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1
end

local function install(server, package)
    vim.notify(("Installing %s through Mason"):format(package.name))

    package:install({}, vim.schedule_wrap(function(success, result)
        if success then
            vim.lsp.enable(server)
        else
            vim.notify(("Mason could not install %s: %s"):format(package.name, result),
                vim.log.levels.ERROR)
        end
    end))
end

function M.enable(servers)
    if vim.fn.has("nvim-0.11") == 0 then
        vim.notify("Language servers need Neovim 0.11 or later.", vim.log.levels.WARN)
        return
    end

    local registry = require("mason-registry")
    local packages = require("mason-lspconfig").get_mappings().lspconfig_to_package

    for _, server in ipairs(servers) do
        local name = packages[server]

        if on_path(server) or not name then
            vim.lsp.enable(server)
        else
            registry.refresh(function()
                local package = registry.get_package(name)

                if package:is_installed() then
                    vim.lsp.enable(server)
                elseif not package:is_installing() then
                    install(server, package)
                end
            end)
        end
    end
end

-- Diagnostics and the mappings Neovim does not already provide (K, grn, gra,
-- grr, gri, gO and [d / ]d are built in).
function M.setup()
    vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { spacing = 2 },
        float = { source = true },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("WorkstationLsp", { clear = true }),
        desc = "Language server key mappings",
        callback = function(args)
            local function map(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
            end

            map("gd", vim.lsp.buf.definition, "Go to definition")
            map("gD", vim.lsp.buf.declaration, "Go to declaration")
            map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
        end,
    })
end

return M
