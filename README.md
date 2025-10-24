**Ubuntu Desktop with NICE DCV**

patched *libdcv.so* for NICE DCV to generate *license.lic* with expiration date of *31-dec-2099*.

license server has been set to `5053@licensing.841973620.net`

links
- https://www.841973620.net:8088/index.php/archives/nice-dcv-crack.html
- https://www.bilibili.com/video/BV1eD47zxEBu

<br>

default
- username: ubuntu
- password: ubuntu

<br><br>

run:
```
docker run -it --rm --name dcv --privileged -p 8443:8443 841973620/nice-dcv:ubuntu22.04
```
or:
```
docker run -it --rm --name dcv --privileged -p 8443:8443 841973620/nice-dcv:ubuntu22.04 [password]
```
or:
```
docker run -it --rm --name dcv --privileged -p 8443:8443 841973620/nice-dcv:ubuntu22.04 [username] [password]
```