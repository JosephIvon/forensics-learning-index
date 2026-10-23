@echo off
rem GIT_ASKPASS 助手：凭据只在进程环境里，不落盘、不进 git config。
rem 用法：set GITHUB_USER=... & set GITHUB_PASS=... 后由 git 调用。
setlocal
echo %~1 | findstr /i "username" >nul
if not errorlevel 1 (
  echo %GITHUB_USER%
) else (
  echo %GITHUB_PASS%
)
endlocal
