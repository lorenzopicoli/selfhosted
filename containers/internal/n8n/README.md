# N8N

### What is it used for

N8N is an automation tool. With it I can choose from a long list of triggers and do endless actions based on that.

One example is using it to use git with obsidian. I have an obsidian git folder that is synced with all my other devices. I use N8N to pull and push to the repo every X seconds effectively giving me versioning to my notes.


### Open questions

- I've had issues with CPU usage where just opening the GUI after a while would kill the host machine by using 300% of the CPU constantly
- Premium lock is a turn off, is there an alternative out there?
- I think I should use the SSH node to do SSH instead of adding the SSH key as volume...

### Volumes

SSH keys are currently passed as a volume (check open questions).

There's also a n8n volume stored in the default location. This volume contains not only logs, but also my workflows which I consider sensitive data in the sense that I can't lose it - so it has to be backed up

### Env vars

No env file is required