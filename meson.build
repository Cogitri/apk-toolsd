project('apk-tools-d', ['c', 'd'], version: '2.10.4')

headers = [
    'deimos/apk-tools/apk_blob.d',
    'deimos/apk-tools/apk_defines.d',
    'deimos/apk-tools/apk_openssl.d',
    'deimos/apk-tools/apk_package.d',
    'deimos/apk-tools/apk_solver_data.d',
    'deimos/apk-tools/apk_io.d',
    'deimos/apk-tools/apk_applet.d',
    'deimos/apk-tools/apk_archive.d',
    'deimos/apk-tools/apk_print.d',
    'deimos/apk-tools/apk_provider_data.d',
    'deimos/apk-tools/apk_version.d',
    'deimos/apk-tools/apk_hash.d',
    'deimos/apk-tools/apk_database.d',
    'deimos/apk-tools/apk_solver.d',
]

install_headers(
    headers,
    subdir: 'd/apk-tools-d/apk-tools-d',
)

cc = meson.get_compiler('c')

apk_tools_dep = cc.find_library('apk')

pkg = import('pkgconfig')

pkg.generate(
    name: 'apk-tools-d',
    subdirs: 'd/apk-tools-d/apk-tools-d',
    version: meson.project_version(),
    description: 'Deimos bindings for the Alpine Package Keeper.',
    libraries: apk_tools_dep,
)
