@echo off
rem GIT_ASKPASS helper for git over HTTPS.
rem Credentials live only in the process environment (GITHUB_USER / GITHUB_PASS);
rem they are never written to disk, to git config, or into any repository.
rem NOTE: keep this file pure ASCII -- cmd.exe reads .cmd in the local codepage,
rem so non-ASCII comment text gets garbled and parsed as commands.
setlocal
echo %~1 | findstr /i "username" >nul
if not errorlevel 1 (
  echo %GITHUB_USER%
) else (
  echo %GITHUB_PASS%
)
endlocal
