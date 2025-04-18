"""A lookup plugin for finding quay.io images used by ansible-test and returning a consolidated list of annotated docker pull commands to retrieve them."""
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os
import re

try:
    import typing as t
except ImportError:
    t = None

from ansible.plugins.lookup import LookupBase


class LookupModule(LookupBase):
    def run(self, terms, variables=None, **kwargs):
        return [get_docker_pull_commands(kwargs['branches'], kwargs['git_cache_path'])]


def get_container_names(branch, git_cache_path):  # type: (str, str) -> t.List[str]
    """Return a list of container image references used in the given branch."""
    base_paths = [
        '.azure-pipelines',
    ]

    if branch == 'stable-2.8':
        base_paths.append('test/runner')
    else:
        base_paths.append('test/lib/ansible_test')

    images = set()

    for base_path in base_paths:
        git_path = os.path.join(git_cache_path, branch, base_path)

        for root, directory_names, file_names in os.walk(git_path):
            for filename in file_names:
                path = os.path.join(root, filename)

                with open(path) as file:
                    content = file.read()

                images.update(re.findall('quay.io/ansible/[^:]+:[0-9]+.[0-9]+.[0-9]+', content))

    return sorted(images)


def get_docker_pull_commands(branches, git_repo_path):  # type: (t.List[str], str) -> t.List[str]
    """Return a list of docker pull commands for container images used in the given branches."""
    images = {
        'quay.io/ansible/azure-pipelines-test-container:4.0.1',
        'quay.io/ansible/azure-pipelines-test-container:6.0.0',
    }

    image_comments = {image: set() for image in images}

    for branch in branches:
        names = get_container_names(branch, git_repo_path)

        for name in names:
            image_comments.setdefault(name, set()).add(branch)
            images.add(name)

    docker_pull = []

    for image in sorted(images, key=split_image_name):
        branches = sorted(image_comments[image], key=split_branch_name)

        comment = ''

        if branches:
            comment += f' {" ".join(branches)}'

        docker_pull.append(f"echo Pulling {image} ...")

        if comment:
            comment = f'  #{comment}'

        docker_pull.append(f'sudo docker pull {image}{comment}')

    docker_pull.append("echo All images have been pulled")

    return docker_pull


def split_image_name(image):  # type: (str) -> t.Tuple[str, int, int, int]
    """Return the given image name split into components for sorting."""
    name, version = image.split(':')
    major, minor, patch = version.split('.')
    return name, int(major), int(minor), int(patch)


def split_branch_name(branch):  # type: (str) -> t.Tuple[t.Union[str, int], ...]
    """Return the given branch name split into components for sorting."""
    if '-' in branch:
        name, version = branch.split('-')
        branch_components = tuple([name] + list(map(int, version.split('.'))))
    else:
        branch_components = tuple([branch])

    return branch_components
