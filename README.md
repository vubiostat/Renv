# Simple R Version Management: Renv

Renv lets you easily switch between multiple versions of R. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

### Renv _does…_

* Let you **change the global R version** on a per-user basis.
* Provide support for **per-project R versions**.
* Allow you to **override the R version** with an environment
  variable.

## Table of Contents

   * [1 How It Works](#section_1)
   * [2 Installation](#section_2)
      * [2.1 Basic GitHub Checkout](#section_2.1)
         * [2.1.1 Upgrading](#section_2.1.1)
      * [2.2 Neckbeard Configuration](#section_2.2)
   * [3 Usage](#section_3)
      * [3.1 Renv global](#section_3.1)
      * [3.2 Renv local](#section_3.2)
      * [3.3 Renv shell](#section_3.3)
      * [3.4 Renv versions](#section_3.4)
      * [3.5 Renv version](#section_3.5)
      * [3.6 Renv rehash](#section_3.6)
      * [3.7 Renv which](#section_3.7)
      * [3.8 Renv whence](#section_3.8)
   * [4 Development](#section_4)
      * [4.1 History](#section_4.1)
      * [4.2 License](#section_4.2)

## <a name="section_1"></a> 1 How It Works

Renv operates on the per-user directory `~/.Renv`. Version names in
Renv correspond to subdirectories of `~/.Renv/versions`. For
example, you might have `~/.Renv/versions/2.13.2` and
`~/.Renv/versions/2.14.0`.

Each version is a working tree with its own binaries, like
`~/.Renv/versions/2.13.2/bin/R` and
`~/.Renv/versions/2.14.0/bin/R`. Renv makes _shim binaries_
for every such binary across all installed versions of R.

These shims are simple wrapper scripts that live in `~/.Renv/shims`
and detect which R version you want to use. They insert the
directory for the selected version at the beginning of your `$PATH`
and then execute the corresponding binary.

Because of the simplicity of the shim approach, all you need to use
Renv is `~/.Renv/shims` in your `$PATH`.

## <a name="section_2"></a> 2 Installation

### <a name="section_2.1"></a> 2.1 Basic GitHub Checkout

This will get you going with the latest version of Renv and make it
easy to fork and contribute any changes back upstream.

1. Check out Renv into `~/.Renv`.

        $ cd
        $ git clone git://github.com/viking/Renv.git .Renv

2. Add `~/.Renv/bin` to your `$PATH` for access to the `Renv`
   command-line utility.

        $ echo 'export PATH="$HOME/.Renv/bin:$PATH"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.

3. Add Renv init to your shell to enable shims and autocompletion.

        $ echo 'eval "$(Renv init -)"' >> ~/.bash_profile

    **Zsh note**: Modify your `~/.zshenv` file instead of `~/.bash_profile`.

4. Restart your shell so the path changes take effect. You can now
   begin using Renv.

        $ exec $SHELL

5. Install R versions into `~/.Renv/versions`. For example, to
   install R 2.14.0, download and unpack the source, then run:

        $ ./configure --prefix=$HOME/.Renv/versions/2.14.0
        $ make
        $ make install

   You can also use [R-build](https://github.com/viking/R-build) to build and install R versions.

6. Rebuild the shim binaries. You should do this any time you install
   a new R binary (for example, when installing a new R version).

        $ Renv rehash

#### <a name="section_2.1.1"></a> 2.1.1 Upgrading

If you've installed Renv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of Renv, use `git pull`:

    $ cd ~/.Renv
    $ git pull

To upgrade to a specific release of Renv, check out the corresponding
tag:

    $ cd ~/.Renv
    $ git fetch
    $ git tag
    v0.1.0
    v0.1.1
    v0.1.2
    v0.2.0
    $ git checkout v0.2.0

### <a name="section_2.2"></a> 2.2 Neckbeard Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`Renv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from rvm, some of you might be
opposed to this idea. Here's what `Renv init` actually does:

1. Sets up your shims path. This is the only requirement for Renv to
   function properly. You can do this by hand by prepending
   `~/.Renv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.Renv/completions/Renv.bash` will set that
   up. There is also a `~/.Renv/completions/Renv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `Renv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   Renv and plugins to change variables in your current shell, making
   commands like `Renv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `Renv` to be a real script rather than a
   shell function, you can safely skip it.

Run `Renv init -` for yourself to see exactly what happens under the
hood.

## <a name="section_3"></a> 3 Usage

Like `git`, the `Renv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### <a name="section_3.1"></a> 3.1 Renv global

Sets the global version of R to be used in all shells by writing
the version name to the `~/.Renv/version` file. This version can be
overridden by a per-project `.Renv-version` file, or by setting the
`RENV_VERSION` environment variable.

    $ Renv global 2.14.0

The special version name `system` tells Renv to use the system R
(detected by searching your `$PATH`).

When run without a version number, `Renv global` reports the
currently configured global version.

### <a name="section_3.2"></a> 3.2 Renv local

Sets a local per-project R version by writing the version name to
an `.Renv-version` file in the current directory. This version
overrides the global, and can be overridden itself by setting the
`RENV_VERSION` environment variable or with the `Renv shell`
command.

    $ Renv local 2.11.1

When run without a version number, `Renv local` reports the currently
configured local version. You can also unset the local version:

    $ Renv local --unset

### <a name="section_3.3"></a> 3.3 Renv shell

Sets a shell-specific R version by setting the `RENV_VERSION`
environment variable in your shell. This version overrides both
project-specific versions and the global version.

    $ Renv shell 2.13.2

When run without a version number, `Renv shell` reports the current
value of `RENV_VERSION`. You can also unset the shell version:

    $ Renv shell --unset

Note that you'll need Renv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`RENV_VERSION` variable yourself:

    $ export RENV_VERSION=2.13.2

### <a name="section_3.4"></a> 3.4 Renv versions

Lists all R versions known to Renv, and shows an asterisk next to
the currently active version.

    $ Renv versions
      2.10.1
      2.11.1
    * 2.14.0 (set by /Users/sam/.Renv/global)

### <a name="section_3.5"></a> 3.5 Renv version

Displays the currently active R version, along with information on
how it was set.

    $ Renv version
    2.14.0 (set by /home/viking/Projects/yaml/.Renv-version)

### <a name="section_3.6"></a> 3.6 Renv rehash

Installs shims for all R binaries known to Renv (i.e.,
`~/.Renv/versions/*/bin/*`). Run this command after you install a new
version of R.

    $ Renv rehash

### <a name="section_3.7"></a> 3.7 Renv which

Displays the full path to the binary that Renv will execute when you
run the given command.

    $ Renv which irb
    /home/viking/.Renv/versions/2.14.0/bin/R

### <a name="section_3.8"></a> 3.8 Renv whence

Lists all R versions with the given command installed.

    $ Renv whence R
    2.13.2
    2.14.0

## <a name="section_4"></a> 4 Development

The Renv source code is [hosted on
GitHub](https://github.com/viking/Renv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/viking/Renv/issues).

### <a name="section_4.1"></a> 4.1 History

Renv is a forked version of [rbenv](https://github.com/sstephenson/rbenv).

### <a name="section_4.2"></a> 4.2 License

(The MIT license)

Copyright (c) 2011 Sam Stephenson, Vanderbilt University

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
