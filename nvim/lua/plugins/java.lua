-- Java language server support.
--   mason.nvim  installs jdtls (the Eclipse Java language server).
--   nvim-jdtls  starts jdtls for Java buffers and adds Java extras,
--               such as opening library classes (jdt:// links) on go-to-definition.

-- Starts jdtls for the current Java buffer, or attaches to the one already
-- running for this project.
local function start_jdtls()
  local mason = vim.fn.stdpath("data") .. "/mason"
  local jdtls_bin = mason .. "/bin/jdtls"

  if vim.fn.executable(jdtls_bin) == 0 then
    vim.notify("jdtls is not installed. Run :MasonInstall jdtls", vim.log.levels.WARN)
    return
  end

  -- Project root: nearest Maven/Gradle wrapper or git repo, else nearest build file.
  local root_dir = vim.fs.root(0, {
    { "mvnw", "gradlew", ".git" },
    { "pom.xml", "build.gradle", "build.gradle.kts" },
  }) or vim.fn.getcwd()

  -- jdtls keeps an index per project. Store it outside /tmp so it survives reboots.
  local project = vim.fn.fnamemodify(root_dir, ":t") .. "-" .. vim.fn.sha256(root_dir):sub(1, 8)
  local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project

  require("jdtls").start_or_attach({
    cmd = {
      jdtls_bin,
      "--jvm-arg=-javaagent:" .. mason .. "/packages/jdtls/lombok.jar",
      "-data", workspace_dir,
    },
    root_dir = root_dir,
    settings = {
      java = {
        -- Fetch real sources for dependencies so go-to-definition shows code, not decompiled stubs.
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
      },
    },
  })
end

return {
  { "mason-org/mason.nvim", opts = {} },
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user.jdtls", { clear = true }),
        pattern = "java",
        callback = start_jdtls,
      })
      -- The Java file that triggered loading this plugin is already open.
      if vim.bo.filetype == "java" then
        start_jdtls()
      end
    end,
  },
}
