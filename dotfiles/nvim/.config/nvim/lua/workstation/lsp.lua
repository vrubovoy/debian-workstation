-- =============================================================================
-- Neovim — language servers
-- =============================================================================
--
-- The servers in M.servers start for their file types in every project. A
-- project can add others in .nvim.lua at its root, with the names from
-- :help lspconfig-all:
--
--     require("workstation.lsp").enable({ "rust_analyzer" })
--
-- A server that is not on PATH is installed through Mason the first time a
-- file of its type is opened. Neovim asks once whether to trust a new or
-- changed .nvim.lua.
--
-- Path:  ~/.config/nvim/lua/workstation/lsp.lua

local M = {}

M.servers = { "clangd", "ts_ls", "basedpyright", "bashls", "lua_ls" }

local function on_path(server)
    local cmd = (vim.lsp.config[server] or {}).cmd
    return type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1
end

local function install(server, name)
    local registry = require("mason-registry")

    registry.refresh(function()
        local package = registry.get_package(name)

        if package:is_installed() then
            vim.lsp.enable(server)
            return
        end

        if package:is_installing() then
            return
        end

        vim.notify(("Installing %s through Mason"):format(name))

        package:install({}, vim.schedule_wrap(function(success, result)
            if success then
                vim.lsp.enable(server)
            else
                vim.notify(("Mason could not install %s: %s"):format(name, result),
                    vim.log.levels.ERROR)
            end
        end))
    end)
end

function M.enable(servers)
    if vim.fn.has("nvim-0.11") == 0 then
        vim.notify("Language servers need Neovim 0.11 or later.", vim.log.levels.WARN)
        return
    end

    local packages = require("mason-lspconfig").get_mappings().lspconfig_to_package

    for _, server in ipairs(servers) do
        local name = packages[server]

        if on_path(server) or not name then
            vim.lsp.enable(server)
        else
            vim.api.nvim_create_autocmd("FileType", {
                pattern = vim.lsp.config[server].filetypes,
                once = true,
                desc = "Install " .. name,
                callback = function() install(server, name) end,
            })
        end
    end
end

-- Diagnostics, the mappings Neovim does not already provide (K, grn, gra, grr,
-- gri, gO and [d / ]d are built in) and the default servers.
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

    -- Lua in Neovim: LuaJIT and the vim API, unless the project has its own
    -- .luarc.json.
    vim.lsp.config("lua_ls", {
        on_init = function(client)
            local root = client.workspace_folders and client.workspace_folders[1].name

            if root and (vim.uv.fs_stat(root .. "/.luarc.json") or vim.uv.fs_stat(root .. "/.luarc.jsonc")) then
                return
            end

            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
                runtime = { version = "LuaJIT" },
                workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            })
        end,
        settings = { Lua = {} },
    })

    M.enable(M.servers)
end

return M
