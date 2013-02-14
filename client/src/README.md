# README for `src`


Each pipeline in `actions/` (called "an action") must be a step with:

- no input
- a primary output (`result`)
- an option `repo` (which specifies which repo to use).  
- a primary `parameters` port (which defines any parameters it accepts).  

The step should be named `client:action-{action}`, and 
the file should be named `actions/{action}.xproc`.

An action must provide ... (xml + text...)
