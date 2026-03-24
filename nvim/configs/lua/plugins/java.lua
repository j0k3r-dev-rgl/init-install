-- nvim-jdtls: wrapper para eclipse.jdt.ls con soporte Java 26
return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  dependencies = {
    "mason-org/mason.nvim",
    "mfussenegger/nvim-dap",
  },
}
