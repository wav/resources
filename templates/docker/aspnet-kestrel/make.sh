#!/bin/sh

[[ -d Home ]] || \
    git clone https://github.com/aspnet/Home

docker build -t asp-net-sample .