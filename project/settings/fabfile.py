from fabric.api import settings, lcd, task
from fabric.context_managers import prefix
from fabric.operations import local as lrun, run
from fabric.state import env

home_path = '/home/vagrant/'
project_path = '/vagrant/project/'
project_client_path = '{}client/'.format(project_path)
project_server_path = '{}server/'.format(project_path)

venv = '. {}venv/bin/activate'.format(project_server_path)
fixtures_path = '{}fixtures/'.format(project_server_path)
fixtures_file = '{}fixtures.txt'.format(fixtures_path)


@task
def local():
    """
    Local Machine
    """
    env.run = lrun
    env.hosts = ['localhost']


@task
def production():
    """
    Production machine
    """
    env.run = run
    env.hosts = ['127.0.0.1']


@task
def clean():
    """
    Remove all .pyc files
    """
    with lcd(project_path):
        env.run("find . -name '*.pyc' -print0|xargs -0 rm", capture=False)


@task
def clean_packages():
    """
    Remove all .pyc files
    """
    with lcd(project_server_path):
        env.run("rm -rf venv/")
    with lcd(project_client_path):
        env.run("rm -rf bower_components/")
        env.run("rm -rf node_modules/")
        env.run("rm -rf staging/")
        env.run("rm -rf release/")

@task
def clear_memcached():
    """
    Clear memcached
    """
    env.run("echo 'flush_all' | nc localhost 11211")


@task
def clear_systemcache():
    """
    Clear System cache
    """
    env.run("#!/bin/sh;sync; echo 3 > /proc/sys/vm/drop_caches")


@task
def kill_server(port=8000):
    """
    Kills running process
    """
    env.run("fuser -k {}/tcp".format(port))


@task
def pip(package):
    """
    Install package using pip (in the format fab local pip:django)
    """
    with prefix(venv):
        env.run('pip install {}'.format(package))


@task
def npm(package):
    """
    Install package using npm (in the format fab local npm:phantomjs)
    """
    with lcd(project_client_path):
        with prefix(venv):
            env.run('npm install {} --save-dev'.format(package))


@task
def backup(fixture=''):
    """
    Backup fixtures
    """
    if fixture:
        with settings(warn_only=True):
            with lcd(project_path):
                with prefix(venv):
                    env.run("rm -rf {}{}.json".format(fixtures_path, fixture.strip()))
                    env.run(
                        "python manage.py dumpdata {0} --format=json --indent=4 >> {1}{0}.json".format(fixture.strip(),
                                                                                                       fixtures_path))
    else:
        with settings(warn_only=True):
            with lcd(project_path):
                with prefix(venv):
                    with open(fixtures_file) as f:
                        for line in f:
                            env.run("rm -rf {}{}.json".format(fixtures_path, line.strip()))
                            env.run(
                                "python manage.py dumpdata {0} --format=json --indent=4 >> {1}{0}.json".format(
                                    line.strip(),
                                    fixtures_path))


@task
def install(fixture=''):
    """
    Install fixtures
    """
    if fixture:
        with settings(warn_only=True):
            with prefix(venv):
                env.run("python manage.py loaddata {}.json".format(fixture.strip()))
    else:
        with settings(warn_only=True):
            with prefix(venv):
                with open(fixtures_file) as f:
                    for line in f:
                        env.run("python manage.py loaddata {}.json".format(line.strip()))



@task
def build_client():
    """
    Build client dependencies.
    """
    with lcd(home_path):
        env.run('sudo rm -rf .npm/*')

    with lcd(project_client_path):
        env.run('npm cache clear')
        env.run("sudo rm -rf npm-debug.log")
        env.run("sudo rm -rf bower_components/")
        env.run("sudo rm -rf node_modules/")
        env.run("npm install")
        with prefix(venv):
            env.run("grunt build")

@task
def build_server():
    """
    Build server dependencies.
    """
    with lcd(project_server_path):
        env.run("rm -rf venv && virtualenv venv") if venv else env.run("virtualenv venv")
        # env.run("pip freeze | grep -v '^-e' | xargs pip uninstall -y")
    with lcd(project_path):
        with prefix(venv):
            env.run("pip install -r server/requirements/local.txt")
            env.run("python manage.py reset_db --noinput")
            env.run("python manage.py migrate --noinput")
    install()

@task
def start():
    """
    Run project
    """
    with lcd(project_path):
        with prefix(venv):
            env.run('python manage.py runserver_plus 0:8000')


@task
def build():
    """
    build client + server
    """
    build_server()
    build_client()



@task
def test():
    """
    Test project
    """
    with lcd(project_client_path):
        with prefix(venv):  # as we need to run python runserver
            env.run("grunt test")
    with lcd(project_path):
        with prefix(venv):
            env.run('python manage.py test')


@task
def deploy():
    """
    Deploy project
    """
    env.run("export DJANGO_CONFIGURATION=Prod")
