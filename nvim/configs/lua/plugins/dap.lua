return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI para el debugger
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<F5>",       function() require("dap").continue() end,          desc = "Debug: Continuar" },
      { "<F10>",      function() require("dap").step_over() end,         desc = "Debug: Step over" },
      { "<F11>",      function() require("dap").step_into() end,         desc = "Debug: Step into" },
      { "<F12>",      function() require("dap").step_out() end,          desc = "Debug: Step out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function()
          require("dap").set_breakpoint(vim.fn.input("Condicion: "))
        end,                                                              desc = "Breakpoint condicional" },
      { "<leader>du", function() require("dapui").toggle() end,          desc = "Toggle DAP UI" },
      { "<leader>dr", function() require("dap").repl.open() end,         desc = "Abrir REPL" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Abrir/cerrar UI automaticamente al iniciar/terminar debug
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      dapui.setup()
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    lazy = true,
  },
}
