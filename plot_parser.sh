#!/bin/sh

ragel -pV $1 > .tmp.dot
dot -Tpng .tmp.dot > parser_plot.png
