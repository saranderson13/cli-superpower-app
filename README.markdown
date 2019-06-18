# Superpower CLI App

Superopower CLI is a Ruby CLI application in which you can explore randomly generated superpowers, create heroes and villains.
Data on superpowers is scraped from "https://powerlisting.fandom.com/".
Data for personality traits is scraped from "https://teachingmadepractical.com/character-traits-list/".

## Installation

Use Bundler to install all gems and dependencies necessary to run the Superpower CLI App.
Navigate to the root folder and enter:

```bash
bundler install
```


## Getting Started

To run the program, navigate to the root folder and enter the following command:

```bash
ruby bin/run
```

Don't worry, the program will take a few moments to start!
It scrapes some initial data to pre-load the power library, and populate it.
It also scrapes some data to populate the arrays for possible personality traits.

Once the program starts, simply follow the command prompt to explore powers and create your own heroes and villains.
Use simple commands, such as numbers and y for 'yes', and n for 'no'.
At most points in the program, you can also type 'exit' to go back to the previous menu, or exit the program.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
