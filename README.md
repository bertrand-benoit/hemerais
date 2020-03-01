:warning: This project is now hosted on [Gitlab](https://gitlab.com/bertrand-benoit/hemerais); switch to it to get newer versions.

# Hemera - Intelligent System
Created in 2010, Hemera aims to be a generic Intelligent System aggregating some more advanced Artificial Intelligence Technologies (speech, speech recognition, facial recognition, form/motion recognition, machine learning ...); with applications in day tasks, domotics and robotics.

This script uses my [scripts-common](https://gitlab.com/bertrand-benoit/scripts-common) project.

## Features
-   speech synthesis
-   speech recognition
-   interpretation of recognized commands
-   highly configurable
-   robust (lots of check are performed)
-   internationalization ability

## First time you clone this repository
After the first time you clone this repository, you need to initialize git submodule:
```bash
git submodule init
git submodule update
```

This way, [scripts-common](https://gitlab.com/bertrand-benoit/scripts-common) project will be available and you can use this tool.

## Configuration files
This tools uses the configuration file feature of the [scripts-common](https://gitlab.com/bertrand-benoit/scripts-common) project.
You can start with **Hemera/config/hemera.conf.sample** sample configuration file.

See [online documentation](https://gitlab.com/bertrand-benoit/hemerais/-/wikis/Hemera:Install) for complete information.

## Quick Start
You can quick start with this [Guide](https://gitlab.com/bertrand-benoit/hemerais/-/wikis/Hemera:QuickStart).

### Get last Hemera release version
You can download [release Tarball](https://gitlab.com/bertrand-benoit/hemerais/releases) (previous versions: [here]( https://github.com/bertrand-benoit/hemerais/releases) and [here](https://sourceforge.net/projects/hemerais/files/Hemera/)).

### Get last Hemera development version
Clone the repository:
```bash
git clone https://gitlab.com/bertrand-benoit/hemerais.git
```

### Demo
You can get demonstration files in **Samples/** sub-directory.

## Help
At any time, you can yet help on available commands, launching the following script (you should update your environment, for instance via your **~/.bashrc** file, to get it in your **PATH**):
```bash
Hemera/scripts/help.sh
```

## All you want to know about Hemera
See [online documentation](https://gitlab.com/bertrand-benoit/hemerais/wikis).

In any tarball, you can get documentation in **doc/** sub-directory.

## Notes
Since 2019, Hemera environment changes from its Desktop version to a new dedicated Robotics one.

In 2015, and then 2020, source code and website have been migrated (from SourceForge to Github, then to Gitlab) to provide you the best experience.

If you are interested in original version:
 * the Website on [SourceForge](https://sourceforge.net/p/hemerais/wiki/Home/)
 * the source code on [SourceForge](https://sourceforge.net/p/hemerais/code/)

## Contributing
Don't hesitate to [contribute](https://opensource.guide/how-to-contribute/) or to contact me if you want to improve the project.
You can [report issues or request features](https://gitlab.com/bertrand-benoit/hemerais/issues) and propose [merge requests](https://gitlab.com/bertrand-benoit/hemerais/merge_requests).

## Versioning
The versioning scheme we use is [SemVer](http://semver.org/).

## Authors
[Bertrand BENOIT](mailto:contact@bertrand-benoit.net)

## License
This project is under the GPLv3 License - see the [LICENSE](LICENSE) file for details
