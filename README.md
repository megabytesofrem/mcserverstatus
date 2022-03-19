# mcserverstatus

Unfinished D library to get the server status of a Minecraft server

## Usage

The project is still unfinished and as such is not yet a library. To test the project you can change the server address in `app.d`. Some servers may not work due to missing SRV record support.

1. [Install Dlang](https://dlang.org/download.html)
2. Change the server address in `app.d` (will change in future)
3. Run `dub run` or `dub build` and then `./mcserverstatus`

### Example Output

```
SERVER INFO

text: A Minecraft Server

version name: 1.16.3
version protocol: 753

players: 0
max players: 20
```

## Todo

- [ ] Error handling
- [ ] Remove hard coded buffer size for TCP request
- [ ] SRV record support
- [ ] Favicon decoding and presenting
- [ ] Wrap code in a library
- [ ] Minecraft color codes -> shell color codes

## D

![og d-man](https://raw.githubusercontent.com/harrego/mcserverstatus/master/.github/dman.png)