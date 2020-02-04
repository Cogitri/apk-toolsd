project('apk-toolsd', ['c', 'd'], version: '2.10.4')

project_soversion = 0

cc = meson.get_compiler('c')

apk_tools_dep = cc.find_library('apk')

subdir('deimos/apk_tools')
