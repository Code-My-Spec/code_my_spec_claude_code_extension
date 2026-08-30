@echo off
rem Claude Code PermissionRequest hook (Windows).
rem Mirrors ./approve — forwards stdin to the cms server's long-polling
rem permissions endpoint and prints the hook response. Falls back to "ask"
rem so Claude Code uses its built-in prompt if anything goes wrong.
rem The id comes from .cms_harness.json in the working copy — the server
rem resolves the checkout from that alone now. cmd.exe has no walk-up, so this
rem reads the file in the current directory only; a hook fired from a
rem subdirectory gets the server's refusal naming `mix cms.harness.onboard`.
setlocal enabledelayedexpansion
if not defined CODEMYSPEC_PORT set "CODEMYSPEC_PORT=4003"
set "CMS_ID="
if exist ".cms_harness.json" (
  for /f "tokens=2 delims=:," %%A in ('findstr /c:"harness_id" ".cms_harness.json"') do (
    set "CMS_ID=%%~A"
    set "CMS_ID=!CMS_ID: =!"
    set "CMS_ID=!CMS_ID:"=!"
  )
)
curl.exe -sf -X POST "http://localhost:%CODEMYSPEC_PORT%/api/permissions/request" ^
  -H "Content-Type: application/json" ^
  -H "X-Harness-Id: !CMS_ID!" ^
  --data-binary @-
if errorlevel 1 echo {"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"ask"}}}
endlocal
