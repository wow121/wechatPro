#!/usr/bin/env python
# vim:fileencoding=utf-8

from colorsys import rgb_to_hsv, hsv_to_rgb
from math import ceil

__all__ = ['hex2rgb',
           'rgb2hex',
           'light',
           'dark',
          ]

def hex2rgb(hexcolor):
    rgb = [(hexcolor >> 16) & 0xff,
           (hexcolor >> 8) & 0xff,
           hexcolor & 0xff
          ]
    return rgb

def rgb2hex(rgbcolor):
    #return '0x%02x%02x%02x' % rgbcolor
    r, g, b = rgbcolor
    # notice '<<' has lower precedence than '+'
    return (r << 16) + (g << 8) + b

def light(color):
    color = map(lambda x: x/float(255), color)
    hsv = list(rgb_to_hsv(*color))
    hsv[2] *= 1.5
    color = hsv_to_rgb(*hsv)
    return map(lambda x:
               255 if int(ceil(x*255)) >= 255 else int(ceil(x*255)), color)

def dark(color):
    color = map(lambda x: x/float(255), color)
    hsv = list(rgb_to_hsv(*color))
    hsv[2] *= 2
    color = hsv_to_rgb(*hsv)
    return map(lambda x:
               255 if int(ceil(x*255)) >= 255 else int(ceil(x*255)), color)