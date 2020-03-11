pkgc = import('pkgconfig')

apk_d_src = [
    'apk_applet.d',
    'apk_archive.d',
    'apk_blob.d',
    'apk_database.d',
    'apk_defines.d',
    'apk_hash.d',
    'apk_io.d',
    'apk_package.d',
    'apk_print.d',
    'apk_provider_data.d',
    'apk_solver.d',
    'apk_solver_data.d',
    'apk_version.d',
]

apk_d_lib = library(
    'apk-toolsd',
    apk_d_src,
    include_directories: src_inc,
    dependencies: [apk_tools_dep, openssld_dep],
)

pkgc.generate(
    apk_d_lib,
    subdirs: 'd/apk-toolsd',
    requires: [apk_tools_dep, openssld_dep],
    description: 'D bindings for the Alpine Package Keeper.',
)

install_headers(
    apk_d_src,
    subdir: 'd/apk-toolsd/deimos/apk_toolsd',
)
