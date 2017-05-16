#!/usr/bin/env bash

# Copyright (C) 2015-2017 Yoann Le Garff, Nicolas Boquet and Yann Le Bras
# navel-installation-scripts is licensed under the Apache License, Version 2.0

#-> BEGIN

#-> set

DIRNAME='dirname'
READLINK='readlink'

#-> set (avoid changing these variables)

dirname=$("${DIRNAME}" $0)
full_dirname=$("${READLINK}" -f ${dirname})

. "${full_dirname}/lib/navel-installer" || exit 1

program_name='navel-hub'

supported_os=(
    'rhel6'
    'rhel7'
    'debian7'
    'debian8'
)

#-> functions

# usage

f_usage() {
    "${ECHO}" 'Usage:'
    "${ECHO}" -e "    ${0} [<options>] <git-branch>\n"
    "${ECHO}" 'Options:'
    "${ECHO}" "    [-x <DIRECTORY>]"
    "${ECHO}" -e "        ${program_name} installation DIRECTORY\n"
    "${ECHO}" '    [-1]'
    "${ECHO}" -e "        Don't try to install ${cpanminus_module}\n"
    "${ECHO}" '    [-l]'
    "${ECHO}" -e "        Return the list of supported operating systems\n"

    exit $1
}

# define

f_global_define() {
    # set

    mandatory_pkg_to_install_via_pkg_manager=(
        'curl'
        'gcc'
        'libxml2'
        'tar'
    )

    source_package_url="${navel_git_remote_url}/${program_name}/archive/${navel_git_remote_branch}.tar.gz"

    if [[ -n "${override_program_install_directory}" ]] ; then
        program_install_directory="${override_program_install_directory}"
    else
        program_install_directory="/opt/${program_name}/"
    fi

    program_user='navel-hub'
    program_group='navel-hub'

    program_home_directory="${program_install_directory}"

    # installation steps

    f_install_step_1() {
        f_pending "Installing packages ${mandatory_pkg_to_install_via_pkg_manager[@]}."

        w_install_pkg "${mandatory_pkg_to_install_via_pkg_manager[@]}"
    }

    f_install_step_2() {
        f_pending "Installing ${cpanminus_module} via ${CURL}."

        "${CURL}" -L "${cpanminus_url}" | "${PERL}" - "${cpanminus_module}"
    }

    f_install_step_3() {
        local program_install_directory_dirname=$("${DIRNAME}" "${program_install_directory}")

        f_pending "Downloading ${source_package_url} in ${program_install_directory}."

        [[ -d "${program_install_directory}" ]] && "${RM}" -r "${program_install_directory}"

        "${CURL}" -L "${source_package_url}" | "${TAR}" xvzf - -C "${program_install_directory_dirname}" && "${MV}" "${program_install_directory_dirname}/${program_name}-${navel_git_remote_branch}" "${program_install_directory}"
    }

    f_install_step_4() {
        f_pending "Creating group ${program_group}."

        w_groupadd "${program_group}"
    }

    f_install_step_5() {
        f_pending "Creating user ${program_user} with home directory ${program_home_directory}."

        w_useradd "${program_user}" "${program_group}" "${program_home_directory}"
    }

    f_install_step_6() {
        f_pending "Recursively chowning (${program_user}:${program_group}) ${program_install_directory}."

        w_chown -R "${program_user}:${program_group}" "${program_install_directory}"
    }

    f_install_step_7() {
        local cpanm_navel_gitchain=$(f_build_cpanm_navel_gitchain navel-{base,mojolicious-plugin-api-stdresponses,api})

        f_pending "Installing ${program_name} dependencies."

        "${CPANM}" $cpanm_navel_gitchain && "${CPANM}" --installdeps "${program_install_directory}"
    }
}

_f_define_for_rhel() {
    # set

    YUM='yum'
    CHKCONFIG='chkconfig'

    mandatory_pkg_to_install_via_pkg_manager+=(
        'libxml2-devel'
    )
}

_f_define_for_debian() {
    # set

    APT_GET='apt-get'
    UPDATE_RC_D='update-rc.d'

    mandatory_pkg_to_install_via_pkg_manager+=(
        'libxml2-dev'
    )
}

f_define_for_rhel6() {
    _f_define_for_rhel
}

f_define_for_rhel7() {
    _f_define_for_rhel
}

f_define_for_debian7() {
    _f_define_for_debian
}

f_define_for_debian8() {
    _f_define_for_debian
}

#-> check opts

while getopts 'x:123l' OPT 2>/dev/null ; do
    case "${OPT}" in
        # t)
            # git_tag=${OPTARG} ;;
        x)
            override_program_install_directory="${OPTARG}" ;;
        1)
            disable_install_step[2]=1 ;;
        l)
            "${PRINTF}" '%s\n' "${supported_os[@]}"

            exit 0

            ;;
        *)
            f_usage 1 ;;
    esac
done

navel_git_remote_branch="${@: -1}"

[[ -z "${navel_git_remote_branch}" ]] && f_usage 1

#-> start install

f_start_install

#-> END
