# Contributing to AtlassianPSVII.Configuration

Happy to see you are interested in helping.

Open an issue to discuss a change, or send a pull request against `master`. Before submitting, run `./Tools/setup.ps1` and `Invoke-Build -Task Lint, .` (lint, build and tests) and make sure they pass.

But here is the gist of it once you have forked the repository:

* before changing the code  

```powershell
git clone https://github.com/<YOUR GITHUB USER>/AtlassianPSVII.Configuration
cd AtlassianPSVII.Configuration
git checkout develop
git checkout -b <NAME FOR YOUR FEATURE>
code .
```

* after making the changes  

```powershell
git add .
git commit -m "<A MESSAGE ABOUT THE CHANGES>"
git push
```

* [create a Pull Request](https://help.github.com/articles/creating-a-pull-request/)
