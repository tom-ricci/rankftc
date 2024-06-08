# rankftc
RankFTC allows you to up your scouting game by comparing your team against the rest of the teams going to a match. Given a team and match, RankFTC generates multiple lists ranking your team against the competition.

Check out the [demo video](https://youtu.be/Fg-wboRkQoY) to see RankFTC in action.

## Install
RankFTC is a Bash script that you download with cURL every time you need to run it. However, this does come with some requirements.

#### **Running on Windows**
Running a Bash script on Windows is especially tricky given how, y'know, it doesn't support Bash. So, you need to run RankFTC inside WSL2.

#### **Dependencies**
Most of RankFTC's dependencies are common to the average distro, with one notable exception, `jq`. It's available on most repositories, so just install it using your package manager of choice. Alternatively, you can visit [this website](https://jqlang.github.io/jq/) to download the binary directly.

## Usage
To use RankFTC, you'll need your team number, the match code for the match you want to compare, and that match's season. Oftentimes you won't know your match code off the top of your head, so you can use RankFTC's search command.

### Match Search
Displays a list of potential matches along with their match codes based on the arguments provided.

#### **Command**
```bash
curl -sL https://rankftc.thomasricci.dev | bash -s -- search <season> <match name>
```

#### **Arguments**
- `season`
  - The first year of the season the match takes place in. For example, for the 2020-2021 season, input 2020. For the 2023-2024 season, input 2023.
- `match name`
  - The name of the match. This doesn't need to be precise; as long as it's close to the name of the match, RankFTC will display it.

#### **Example**
To find the Massachusetts State Championship for the 2023-2024 CENTERSTAGE season, use:
```bash
curl -sL https://rankftc.thomasricci.dev | bash -s -- search 2023 "Massachusetts State Championship"
```

### Display Rankings
Displays four tables, one for each OPR ranking (total, auto, tele-op, and endgame OPRs) where every team with an OPR ranking higher than your team are highlighted green, your team is bolded and highlighted blue, and the teams below your team are highlighted red. 

Also, saves tab-seperated-value files of each table in the directory the command was executed in.

#### **Command**
```bash
curl -sL https://rankftc.thomasricci.dev | bash -s -- rank <season> <match code> <team number>
```

#### **Arguments**
- `season`
    - The first year of the season the match takes place in. For example, for the 2020-2021 season, input 2020. For the 2023-2024 season, input 2023.
- `match code`
    - The match code of the match. To find this, use RankFTC's **Match Search** command.
- `team number`
  - Your team's number.

#### **Example**
To compare team 19460 to the current rankings of the other teams competing in Massachusetts State Championship for the 2023-2024 CENTERSTAGE season, use:
```bash
curl -sL https://rankftc.thomasricci.dev | bash -s -- rank 2023 USMACMP 19460
```

## Contributing
This is a hacky, poorly written Bash script, however if you want to add something go for it. I built it such that it should be fine as long as [its data source](https://ftcscout.org) stays online, but if any issues do arise, know that I don't plan to fix them. This was a little weekend project&mdash;not battle-tested software.
