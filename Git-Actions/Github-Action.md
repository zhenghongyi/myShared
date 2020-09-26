# Github-Actions

Github actions 是 Github 推出的持续集成服务。Github 将持续集成中的各个操作称为 actions，由于很多操作在不同项目的需求是类似的，所以 Github 推出 [Actions MarketPlace](https://github.com/marketplace?type=actions)，让开发者共享这些操作脚本。

Github 还提供以下配置的服务器作为 runner（也就是所谓的 Github-host），用来运行持续集成任务。

* 2-core CPU
* 7 GB of RAM memory
* 14 GB of SSD disk space


## 示例

以下是一个默认基于 Github-host的 workflow 例子，用来运行一个 xcode 项目的测试用例：

```
name: CI

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    runs-on: macOS-latest

    steps:
    - uses: actions/checkout@v2

    - name: Print path
      run: echo *

    - name: Run unit-test
      run: |
        cd HtmlParser
        xcodebuild test -scheme HtmlParser -target HtmlParserTests -destination 'platform=iOS Simulator,name=iPhone 11 Pro Max,OS=13.6'
```
之后每次在 master 分支拉取或者提交代码，都会触发事件，自动运行一次测试用例，我们可以在 Action 栏目中查看到每次任务的结果。

## 基本概念

GitHub Actions 有一些自己的术语。

1. workflow （工作流程）：持续集成一次运行的过程，就是一个 workflow。

2. job （任务）：一个 workflow 由一个或多个 jobs 构成，含义是一次持续集成的运行，可以完成多个任务。

3. step（步骤）：每个 job 由多个 step 构成，一步步完成。

4. action （动作）：每个 step 可以依次执行一个或多个命令（action）。

![组成示意](https://docs.github.com/assets/images/help/images/overview-actions-design.png)

## workflow

workflow 文件采用YAML格式，后缀名为`.yml`。放在`.github/workflows`目录下。

### name

设定当前workflow的名称，在 action page 上可以查看到。如果省略名称，则GitHub会将其设置为相对于存储库根目录的工作流文件路径。

### on

(<font color=FF0000>必填</font>) 指定 workflow 的触发事件。

例如：单个事件触发

`on: push  # push事件时触发`

或者：多个事件触发

`on: [push, pull_request]`

[更多触发方式](https://docs.github.com/en/actions/reference/events-that-trigger-workflows)

### jobs

jobs 是 workflow 的主体，表示要执行的一系列任务。

#### `jobs.<job_id>`

每个 job 必须有一个 id，这个 id 相对于 jobs 唯一
<br/><br/>

#### `jobs.<job_id>.name`

指定每一个 job 的名字
<br/><br/>

#### `jobs.<job_id>.needs`

每个 job 之间默认是并行执行的，可以通过`needs`指定执行顺序

```
jobs:
  job1:
  job2:
    needs: job1
  job3:
    needs: [job1, job2]
```
<br/>

#### `jobs.<job_id>.runs-on`

(<font color=FF0000>必填</font>) 指定运行的机器。在 Github-host 为我们提供的选择有

Virtual environment | YAML workflow label
--- | ---
Windows Server 2019 | windows-latest or windows-2019
Ubuntu 20.04 | ubuntu-20.04
Ubuntu 18.04 | ubuntu-latest or ubuntu-18.04
Ubuntu 16.04 | ubuntu-16.04
macOS Catalina 10.15 | macos-latest or macos-10.15

如果配置为`runs-on:self-host`，则表示在我们自行配置的机器上运行
<br/><br/>

#### `jobs.<jobs_id>.outputs`

当前 job 的输出映射表，输出的值都是字符串类型，输出值可应用于下一个步骤

```
jobs:
  job1:
    runs-on: ubuntu-latest
    # Map a step output to a job output
    outputs:
      output1: ${{ steps.step1.outputs.test }}
      output2: ${{ steps.step2.outputs.test }}
    steps:
    - id: step1
      run: echo "::set-output name=test::hello"
    - id: step2
      run: echo "::set-output name=test::world"
  job2:
    runs-on: ubuntu-latest
    needs: job1
    steps:
    - run: echo ${{needs.job1.outputs.output1}} ${{needs.job1.outputs.output2}}
```
<br/>

#### `jobs.<job_id>.env`

job 里的环境变量表，当前 job 中所有步骤都可以访问到。也可以为整个 workflow 或者单个步骤创建环境变量。

```
jobs:
  job1:
    env:
      FIRST_NAME: Mona
```

### steps

#### `steps.name`

指定步骤的名称。
<br/><br/>

#### `steps.uses`

指定使用到的 action。每一个action就是一个脚本，如果你需要某个 action，可以不必自己写复杂的脚本，直接引用他人写好的 action 即可，整个持续集成过程，就变成了一个 actions 的组合。GitHub 做了一个[官方市场](https://github.com/marketplace?type=actions)，可以搜索到他人提交的 actions。

Github 推荐使用 action 时，指定 SHA 、分支或者版本号等，否则 action 的作者在发布更新时，可能会中断正在构建的任务，或者导致其他意外。

```
steps:    
  # Reference a specific commit
  - uses: actions/setup-node@74bc508
  # Reference the major version of a release
  - uses: actions/setup-node@v1
  # Reference a minor version of a release
  - uses: actions/setup-node@v1.2
  # Reference a branch
  - uses: actions/setup-node@master
```
<br/>

#### `steps.env`

为当前步骤设定的环境变量。如果命名有重复，在当前步骤中，使用当前步骤指定的环境变量。

```
steps:
  - name: My first action
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      FIRST_NAME: Mona
      LAST_NAME: Octocat
```
<br/>

#### `steps.run`

运行的命令程序，每一个 run 代表一个进程，可以指定名称，默认通过 shell 命令来运行。

使用`working-directory`，可以指定在哪个文件夹下执行命令

```
# 单行命令
- name: Install Dependencies
  run: npm install
  
# 多行命令
- name: Clean install dependencies and build
  run: |
    npm ci
    npm run build
    
# working-directory 指定目录
- name: Clean temp directory
  run: rm -rf *
  working-directory: ./temp
```
可以通过`shell`字段，来指定使用其他平台语言来执行命令程序。

Supported platform | shell parameter	| Description | Command run internally
--- | --- | --- | ---
All	 | bash | The default shell on non-Windows platforms with a fallback to sh. When specifying a bash shell on Windows, the bash shell included with Git for Windows is used. | bash --noprofile --norc -eo pipefail {0}
All	 | pwsh | The PowerShell Core. GitHub appends the extension .ps1 to your script name. | pwsh -command "& '{0}'"
All	 | python | Executes the python command. | python {0}
Linux / macOS	 | sh | The fallback behavior for non-Windows platforms if no shell is provided and bash is not found in the path. | sh -e {0}
Windows | cmd	 | GitHub appends the extension .cmd to your script name and substitutes for {0}. | %ComSpec% /D /E:ON /V:OFF /S /C "CALL "{0}"".
Windows | owershell | This is the default shell used on Windows. The Desktop PowerShell. GitHub appends the extension .ps1 to your script name. | powershell -command "& '{0}'".

例如：

```
Windows下使用 cmd
steps:
  - name: Display the path
    run: echo %PATH%
    shell: cmd
    
使用 python 脚本
steps:
  - name: Display the path
    run: |
      import os
      print(os.environ['PATH'])
    shell: python
```
<br/>

#### steps.with

通过定义键值对，来出入 action 所需的参数。输入参数会被设置为环境变量，这些环境变量名称是以`INPUT_`为开头的统一大写。

```
jobs:
  my_first_job:
    steps:
      - name: My first step
        uses: actions/hello_world@master
        with:
          first_name: Mona
          middle_name: The
          last_name: Octocat      
```
传入了三个参数(first_name, middle_name, 和 last_name) ，这三个值将会被 hello_world action 捕获，可以通过使用 INPUT_FIRST_NAME, INPUT_MIDDLE_NAME, 和 INPUT_LAST_NAME 三个环境变量来访问这三个参数。

## self-host

推荐是使用 Github 为我们配置好的机器，去执行持续集成任务，也可以我们指定自己的设备来完成。

在 Github 上，我们可以切换到 Setting - Actions 栏目，点击`Add Runner`来配置我们自己的 Runner。点击进去后会有基本的步骤指导：

```
Download
// Create a folder
$ mkdir actions-runner && cd actions-runner
// Download the latest runner package
$ curl -O -L https://github.com/actions/runner/releases/download/v2.273.4/actions-runner-osx-x64-2.273.4.tar.gz
// Extract the installer
$ tar xzf ./actions-runner-osx-x64-2.273.4.tar.gz

Configure
// Create the runner and start the configuration experience
$ ./config.sh --url https://github.com/zhenghongyi/autoTest --token ABLCCF3W3XMFJTPCBNVHQ2S7NRKU4
// Last step, run it!
$ ./run.sh

Using your self-hosted runner
// Use this yaml in your workflow file for each job
runs-on: self-hosted
```
根据系统不同，下载合适的压缩包并解压；配置到我们的仓库，同时修改 workflow 文件中，需要在 self-host 执行的 job 的`runs-on`，最终运行脚本。

## action

我们可以编写自己的 action，aciton 可以选择的语言有：

Type | Operating system
--- | ---
Docker container | Linux
JavaScript | Linux, MacOS, Windows
Composite run steps | Linux, MacOS, Windows

JavaScript 相比 Docker container，速度会更快，但要求打包的代码必须是纯 JavaScript 的，不能依赖于其他二进制文件，但可以使用环境中已有的二进制文件。

自定义的 action 统一放在`.github/actions`目录下，workflow 是通过查找指定目录下的`action.yml`或`action.yaml`来执行，所以如果有多个 action ，在`actions`目录下分开建各自文件夹。

```
hello_world_job:
    runs-on: self-hosted
    name: A job to say hello
    steps:
    - name: Hello world action step
      # 指定使用 hello-world-action 目录下的 action.yml 文件
      uses: ./.github/actions/hello-world-action
```

### JavaScript action

#### 准备

1. 下载安装 Node.js（是的，实际上使用的就是nodejs）
2. 进入到自建的 action 目录下，执行`npm init -y`

#### 创建 metadata 文件

在目录下创建`action.yml`，这个是 action 的主要入口文件，命名固定

```
name: 'Hello World'
description: 'Greet someone and record the time'
inputs:
  who-to-greet:  # id of input
    description: 'Who to greet'
    required: true
    default: 'World'
outputs:
  time: # id of output
    description: 'The time we greeted you'
runs:
  using: 'node12'
  main: 'index.js'
```
这里接收了输入`who-to-greet`和输出`time `

然后创建上面提到的`index.js`

```
const core = require('@actions/core');
const github = require('@actions/github');

try {
  // `who-to-greet` input defined in action metadata file
  const nameToGreet = core.getInput('who-to-greet');
  console.log(`Hello ${nameToGreet}!`);
  const time = (new Date()).toTimeString();
  core.setOutput("time", time);
  // Get the JSON webhook payload for the event that triggered the workflow
  const payload = JSON.stringify(github.context.payload, undefined, 2)
  console.log(`The event payload: ${payload}`);
} catch (error) {
  core.setFailed(error.message);
}
```
`@actions/core`和`@actions/github`都是 Node.js 包，前者用于输入输出变量，后者提供 Github action 的上下文信息。这里我们获取了输入的`who-to-greet`信息并打印，输出了时间和触发事件的相关信息

最后在 workflow 中添加新的 job

```
...
jobs:
 ...
 hello_world_job:
   runs-on: self-hosted
   name: A job to say hello
   steps:
   - name: Hello world action step
     id: hello
     uses: ./.github/actions
     with:
       who-to-greet: 'Mona the Octocat'
   # Use the output from the `hello` step
   - name: Get the output time
     run: echo "The time was ${{ steps.hello.outputs.time }}"
```
![输出效果](https://docs.github.com/assets/images/help/repository/javascript-action-workflow-run.png)

### 参考链接

* [GitHub Actions 入门教程](http://www.ruanyifeng.com/blog/2019/09/getting-started-with-github-actions.html)
* [官方文档](https://docs.github.com/en/actions)