% Crossbow: Parallel short read genotyping in the cloud
% Ben Langmead and Michael C. Schatz
% http://bowtie-bio.sf.net/crossbow

# What is Crossbow?

[Crossbow] is a scalable, portable, and automatic Cloud Computing tool for
finding SNPs from short read data.  Crossbow employs [Bowtie] and a modified
version of [SOAPsnp] to perform the short read alignment and SNP calling
respectively.  Crossbow is designed to be easy to run (a) in "the cloud" (in
this case, Amazon's [Elastic MapReduce] service), (b) on any [Hadoop] cluster,
or (c) on any single computer, without [Hadoop]. Crossbow exploits the
availability of multiple computers and processors where possible.

[Crossbow]: http://bowtie-bio.sf.net/crossbow
[Bowtie]:   http://bowtie-bio.sf.net
[SOAPsnp]:  http://soap.genomics.org.cn/soapsnp.html
[Elastic MapReduce]: http://aws.amazon.com/elasticmapreduce "Amazon Elastic MapReduce"

# A word of caution

Renting resources from [Amazon Web Services] (AKA [AWS]), costs money,
regardless of whether your experiment ultimately succeeds or fails.  In some
cases, Crossbow or its documentation may be partially to blame for a failed
experiment.  While we are happy to accept bug reports, we do not accept
responsibility for financial damage caused by these errors.  Crossbow is
provided "as is" with no warranty.  See `LICENSE` file.

[Amazon Web Services]: http://aws.amazon.com
[Amazon EC2]: http://aws.amazon.com/ec2
[Amazon S3]: http://aws.amazon.com/s3
[Amazon EMR]: http://aws.amazon.com/elasticmapreduce
[Amazon SimpleDB]: http://aws.amazon.com/simpledb
[AWS]: http://aws.amazon.com

# Crossbow modes and prerequisites

Crossbow can be run in four different ways.

1. **Via the [Crossbow web interface]**

   In this case, the [Crossbow] code and the user interface are installed on EC2
   web servers.  Also, the computers running the Crossbow computation are rented
   from Amazon, and the user must have [EC2], [EMR], [S3] and [SimpleDB]
   accounts and must pay the [going rate] for the resources used.  The user does
   not need any special software besides a web browser and, in most cases, an
   [S3 tool].

[S3 tool]: #s3-tools
[Crossbow web interface]: http://bowtie-bio.sf.net/crossbow/ui.html

2. **On Amazon [Elastic MapReduce] via the command-line**
   
   In this case, the Crossbow code is hosted by Amazon and the computers running
   the Crossbow computation are rented from Amazon. However, the user must
   install and run (a) the Crossbow scripts, which require [Perl] 5.6 or later,
   (b) Amazon's [`elastic-mapreduce`] script, which requires Ruby 1.8 or later,
   and (c) an [S3 tool].  The user must have [EC2], [EMR], [S3] and [SimpleDB]
   accounts and must pay the [going rate] for the resources used.

[S3 tool]: #s3-tools

3. **On a [Hadoop] cluster via the command-line**
   
   In this case, the Crossbow code is hosted on your [Hadoop] cluster, as are
   supporting tools: [Bowtie], [SOAPsnp], and possibly [`fastq-dump`].
   Supporting tools must be installed on all cluster nodes, but the Crossbow
   scripts need only be installed on the master. Crossbow was tested with
   [Hadoop] versions 0.20 and 0.20.205, and might also be compatible with other
   versions newer than 0.20. Crossbow scripts require [Perl] 5.6 or later.
   
4. **On any computer via the command-line**
   
   In this case, the Crossbow code and all supporting tools ([Bowtie],
   [SOAPsnp], and possibly [`fastq-dump`])  must be installed on the computer
   running Crossbow. Crossbow scripts require [Perl] 5.6 or later.  The user
   specifies the maximum number of CPUs that Crossbow should use at a time. 
   This mode does *not* require [Java] or [Hadoop].

[Amazon EMR]: http://aws.amazon.com/elasticmapreduce
[Elastic MapReduce]: http://aws.amazon.com/elasticmapreduce
[EMR]: http://aws.amazon.com/elasticmapreduce
[S3]: http://aws.amazon.com/s3
[EC2]: http://aws.amazon.com/ec2
[going rate]: http://aws.amazon.com/ec2/#pricing
[Elastic MapReduce web interface]: https://console.aws.amazon.com/elasticmapreduce/home
[AWS Console]: https://console.aws.amazon.com
[AWS console]: https://console.aws.amazon.com
[`elastic-mapreduce`]: http://aws.amazon.com/developertools/2264?_encoding=UTF8&jiveRedirect=1
[Java]: http://java.sun.com/
[Hadoop]: http://hadoop.apache.org/
[R]: http://www.r-project.org/
[Bioconductor]: http://www.bioconductor.org/
[Perl]: http://www.perl.org/get.html

# Preparing to run on Amazon Elastic MapReduce

Before running Crossbow on [EMR], you must have an [AWS] account with the
appropriate features enabled.  You may also need to [install Amazon's
`elastic-mapreduce` tool].  In addition, you may want to install an [S3 tool],
though most users can simply use [Amazon's web interface for S3], which requires
no installation.

If you plan to run Crossbow exclusively on a single computer or on a [Hadoop]
cluster, you can skip this section.

[Amazon's web interface for S3]: https://console.aws.amazon.com/s3/home
[Installing Amazon's `elastic-mapreduce` tool]: #installing-amazons-elastic-mapreduce-tool

1. Create an AWS account by navigating to the [AWS page].  Click "Sign Up Now"
   in the upper right-hand corner and follow the instructions. You will be asked
   to accept the [AWS Customer Agreement].

2. Sign up for [EC2] and [S3].  Navigate to the [Amazon EC2] page, click on
   "Sign Up For Amazon EC2" and follow the instructions.  This step requires you
   to enter credit card information.  Once this is complete, your AWS account
   will be permitted to use [EC2] and [S3], which are required.

3. Sign up for [EMR].  Navigate to the [Elastic MapReduce] page, click on "Sign
   up for Elastic MapReduce" and follow the instructions. Once this is complete,
   your AWS account will be permitted to use [EMR], which is required.

4. Sign up for [SimpleDB].  With [SimpleDB] enabled, you have the option of
   using the [AWS Console]'s [Job Flow Debugging] feature.  This is a convenient
   way to monitor your job's progress and diagnose errors.

5. *Optional*: Request an increase to your instance limit.  By default, Amazon
   allows you to allocate EC2 clusters with up to 20 instances (virtual
   computers). To be permitted to work with more instances, fill in the form on
   the [Request to Increase] page.  You may have to speak to an Amazon
   representative and/or wait several business days before your request is
   granted.

To see a list of AWS services you've already signed up for, see your [Account
Activity] page.  If "Amazon Elastic Compute Cloud", "Amazon Simple Storage
Service", "Amazon Elastic MapReduce" and "Amazon SimpleDB" all appear there, you
are ready to proceed.

Be sure to make a note of the various numbers and names associated with your
accounts, especially your Access Key ID, Secret Access Key, and your EC2 key
pair name.  You will have to refer to these and other account details in the
future.

[install Amazon's `elastic-mapreduce` tool]: #installing-amazons-elastic-mapreduce-tool
[AWS Customer Agreement]: http://aws.amazon.com/agreement/
[Request to Increase]: http://aws.amazon.com/contact-us/ec2-request/
[Job Flow Debugging]: http://docs.amazonwebservices.com/ElasticMapReduce/latest/DeveloperGuide/DebuggingJobFlows.html
[SimpleDB]: http://aws.amazon.com/simpledb/
[Account Activity]: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?ie=UTF8&action=activity-summary

## Installing Amazon's `elastic-mapreduce` tool

Read this section if you plan to run Crossbow on [Elastic MapReduce] via the
command-line tool.  Skip this section if you are not using [EMR] or if you plan
to run exclusively via the [Crossbow web interface].

To install Amazon's `elastic-mapreduce` tool, follow the instructions in Amazon
Elastic MapReduce developer's guide for [How to Download and Install Ruby and
the Command Line Interface].  That document describes:

[How to Download and Install Ruby and the Command Line Interface]: http://aws.amazon.com/developertools/2264?_encoding=UTF8&jiveRedirect=1

1. Installing an appropriate version of [Ruby], if necessary.

2. Setting up an EC2 keypair, if necessary.

3. Setting up a credentials file, which is used by the `elastic-mapreduce` tool
   for authentication.
   
   For convenience, we suggest you name the credentials file `credentials.json`
   and place it in the same directory with the `elastic-mapreduce` script. 
   Otherwise you will have to specify the credential file path with the
   [`--credentials`] option each time you run `cb_emr`.

We strongly recommend using a version of the `elastic-mapreduce` Ruby script
released on or after December 8, 2011.  This is when the script switched to
using Hadoop v0.20.205 by default, which is the preferred way of running Myrna.

[Ruby]: http://www.ruby-lang.org/
[Setting up an EC2 keypair]: http://docs.amazonwebservices.com/ElasticMapReduce/latest/DeveloperGuide/index.html?download_ruby.html

We also recommend that you add the directory containing the `elastic-mapreduce`
tool to your `PATH`.  This allows Crossbow to locate it automatically. 
Alternately, you can specify the path to the `elastic-mapreduce` tool via the
[`--emr-script`] option when running `cb_emr`.

[AWS]: http://aws.amazon.com/ "Amazon Web Services"
[AWS page]: http://aws.amazon.com/ "Amazon Web Services"
[AWS Getting Started Guide]: http://docs.amazonwebservices.com/AWSEC2/latest/GettingStartedGuide/

## S3 tools

Running on [EMR] requires exchanging files via the cloud-based [S3] filesystem. 
[S3] is organized as a collection of [S3 buckets] in a global namespace.  [S3
charges] are incurred when transferring data to and from [S3] (but transfers
between [EC2] and [S3] are free), and a per-GB-per-month charge applies when
data is stored in [S3] over time.

To transfer files to and from [S3], use an S3 tool.  Amazon's [AWS Console] has
an [S3 tab] that provides a friendly web-based interface to [S3], and doesn't
require any software installation.  [s3cmd] is a very good command-line tool
that requires [Python] 2.4 or later. [S3Fox Organizer] is another GUI tool that
works as a [Firefox] extension.  Other tools include [Cyberduck] (for Mac OS
10.6 or later) and [Bucket Explorer] (for Mac, Windows or Linux, but commercial
software).

[S3]: http://aws.amazon.com/s3/
[S3 tab]: https://console.aws.amazon.com/s3/home
[s3cmd]: http://s3tools.org/s3cmd
[Python]: http://www.python.org/download/
[Firefox]: http://www.mozilla.com/firefox/
[S3 buckets]: http://docs.amazonwebservices.com/AmazonS3/latest/gsg/
[S3 bucket]: http://docs.amazonwebservices.com/AmazonS3/latest/gsg/
[S3 charges]: http://aws.amazon.com/s3/#pricing
[S3Fox Organizer]: http://www.s3fox.net/
[Cyberduck]: http://cyberduck.ch/
[Bucket Explorer]: http://www.bucketexplorer.com/

# Installing Crossbow

[Installing Crossbow]: #installing-crossbow

Crossbow consists of a set of [Perl] and shell scripts, plus supporting tools:
[Bowtie] and [SOAPsnp] .  If you plan to run Crossbow via the [Crossbow web
interface] exclusively, there is nothing to install. Otherwise:

1.  Download the desired version of Crossbow from the [sourceforge site]

2.  [Extract the zip archive]

3.  Set the `CROSSBOW_HOME` environment variable to point to the extracted
    directory (containing `cb_emr`)

4.  *If you plan to run on a local computer or [Hadoop] cluster*:

    If using Linux or Mac OS 10.6 or later, you likely don't have to install
    [Bowtie] or [SOAPsnp], as Crossbow comes with compatible versions of both
    pre-installed.  Test this by running:

        $CROSSBOW_HOME/cb_local --test

    If the install test passes, installation is complete.
    
    If the install test indicates [Bowtie] is not installed, obtain or build a
    `bowtie` binary v0.12.8 or higher and install it by setting the
    `CROSSBOW_BOWTIE_HOME` environment variable to `bowtie`'s enclosing
    directory.  Alternately, add the enclosing directory to your `PATH` or
    specify the full path to `bowtie` via the `--bowtie` option when running
    Crossbow scripts.

    If the install test indicates that [SOAPsnp] is not installed, build the
    `soapsnp` binary using the sources and makefile in `CROSSBOW_HOME/soapsnp`. 
    You must have compiler tools such as GNU `make` and `g++` installed for this
    to work.  If you are using a Mac, you may need to install the [Apple
    developer tools].  To build the `soapsnp` binary, run:

        make -C $CROSSBOW_HOME/soapsnp

    Now install `soapsnp` by setting the `CROSSBOW_SOAPSNP_HOME` environment
    variable to `soapsnp`'s enclosing directory. Alternately, add the enclosing
    directory to your `PATH` or specify the full path to `soapsnp` via the
    `--soapsnp` option when running Crossbow scripts.
    
5.  *If you plan to run on a [Hadoop] cluster*, you may need to manually copy
    the `bowtie` and `soapsnp` executables, and possibly also the `fastq-dump`
    executable, to the same path on each of your [Hadoop] cluster nodes.  You
    can avoid this step by installing `bowtie`, `soapsnp` and `fastq-dump` on a
    filesystem shared by all [Hadoop] nodes (e.g. an [NFS share]).  You can also
    skip this step if [Hadoop] is installed in [pseudo distributed] mode,
    meaning that the cluster really consists of one node whose CPUs are treated
    as distinct slaves.

[NFS share]: http://en.wikipedia.org/wiki/Network_File_System_(protocol)
[pseudo distributed]: http://hadoop.apache.org/common/docs/current/quickstart.html#PseudoDistributed

## The SRA toolkit

The [Sequence Read Archive] (SRA) is a resource at the [National Center for
Biotechnology Information] (NCBI) for storing sequence data from modern
sequencing instruments.  Sequence data underlying many studies, including very
large studies, can often be downloaded from this archive.

The SRA uses a special file format to store archived read data.  These files end
in extensions [`.sra`], and they can be specified as inputs to Crossbow's
preprocessing step in exactly the same way as [FASTQ] files.

However, if you plan to use [`.sra`] files as input to Crossbow in either
[Hadoop] mode or in single-computer mode, you must first install the [SRA
toolkit]'s `fastq-dump` tool appropriately.  See the [SRA toolkit] page for
details about how to download and install.

When searching for the `fastq-dump` tool at runtime, Crossbow searches the
following places in order:

1. The path specified in the [`--fastq-dump`] option
2. The directory specified in the `$CROSSBOW_SRATOOLKIT_HOME` environment
   variable.
3. In the system `PATH`

[Sequence Read Archive]: http://www.ncbi.nlm.nih.gov/books/NBK47533/
[National Center for Biotechnology Information]: http://www.ncbi.nlm.nih.gov/
[SRA toolkit]: http://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?cmd=show&f=software&m=software&s=software

# Running Crossbow

The commands for invoking Crossbow from the command line are:

`$CROSSBOW_HOME/cb_emr` (or just `cb_emr` if `$CROSSBOW_HOME` is in the `PATH`)
for running on [EMR].  See [Running Crossbow on EMR via the command line] for
details.

`$CROSSBOW_HOME/cb_hadoop` (or just `cb_hadoop` if `$CROSSBOW_HOME` is in the
`PATH`) for running on [Hadoop].  See [Running Crossbow on a Hadoop cluster via
the command line] for details.

`$CROSSBOW_HOME/cb_local` (or just `cb_local` if `$CROSSBOW_HOME` is in the
`PATH`) for running locally on a single computer.  See [Running Crossbow on a
single computer via the command line] for details.

[Apple developer tools]: http://developer.apple.com/technologies/tools/
[NFS share]: http://en.wikipedia.org/wiki/Network_File_System_(protocol)
[pseudo distributed]: http://hadoop.apache.org/common/docs/current/quickstart.html#PseudoDistributed
[sourceforge site]: http://bowtie-bio.sf.net/crossbow
[Extract the zip archive]: http://en.wikipedia.org/wiki/ZIP_(file_format)
[Running Crossbow on EMR via the command line]: #running-crossbow-on-emr-via-the-command-line
[Running Crossbow on a Hadoop cluster via the command line]: #running-crossbow-on-a-hadoop-cluster-via-the-command-line
[Running Crossbow on a single computer via the command line]: #running-crossbow-on-a-single-computer-via-the-command-line

# Running Crossbow on EMR via the EMR web interface

## Prerequisites

1. Web browser
2. [EC2], [S3], [EMR], and [SimpleDB] accounts.  To check which ones you've
   already enabled, visit your [Account Activity] page.
3. A tool for browsing and exchanging files with [S3]
    a. The [AWS Console]'s [S3 tab] is a good web-based tool that does not
       require software installation
    b. A good command line tool is [s3cmd]
    c. A good GUI tool is [S3Fox Organizer], which is a Firefox Plugin
    d. Others include [Cyberduck], [Bucket Explorer]
3. Basic knowledge regarding:
    a. [What S3 is], [what an S3 bucket is], how to create one, how to upload a
       file to an S3 bucket from your computer (see your S3 tool's documentation).
    b. How much AWS resources [will cost you]

[Account Activity]: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?ie=UTF8&action=activity-summary
[s3cmd]: http://s3tools.org/s3cmd
[S3Fox Organizer]: http://www.s3fox.net/
[Cyberduck]: http://cyberduck.ch/
[Bucket Explorer]: http://www.bucketexplorer.com/
[What S3 is]: http://aws.amazon.com/s3/
[what an S3 bucket is]: http://docs.amazonwebservices.com/AmazonS3/latest/gsg/
[will cost you]: http://aws.amazon.com/ec2/#pricing

## To run

1.  *If the input reads have not yet been preprocessed by Crossbow* (i.e. input
    is [FASTQ] or [`.sra`]), then first (a) prepare a [manifest file] with URLs
    pointing to the read files, and (b) upload it to an [S3] bucket that you
    own. See your [S3] tool's documentation for how to create a bucket and
    upload a file to it.  The URL for the [manifest file] will be the input URL
    for your [EMR] job.

    *If the input reads have already been preprocessed by Crossbow*, make a note
    of of the [S3] URL where they're located.  This will be the input URL for
    your [EMR] job.

2.  *If you are using a pre-built reference jar*, make a note of its [S3] URL. 
    This will be the reference URL for your [EMR] job.  See the [Crossbow
    website] for a list of pre-built reference jars and their URLs.
   
    *If you are not using a pre-built reference jar*, you may need to [build the
    reference jars] and/or upload them to an [S3] bucket you own.  See your [S3
    tool]'s documentation for how to create a bucket and upload to it.  The URL
    for the main reference jar will be the reference URL for your [EMR] job.

[Crossbow website]: http://bowtie-bio.sf.net/crossbow
[build the reference jars]: #reference-jars
[S3 tool]: #s3-tools
[`.sra`]: http://www.ncbi.nlm.nih.gov/books/NBK47540/

3. In a web browser, go to the [Crossbow web interface].

4. Fill in the form according to your job's parameters.  We recommend filling in
   and validating the "AWS ID" and "AWS Secret Key" fields first.  Also, when
   entering S3 URLs (e.g. "Input URL" and "Output URL"), we recommend that users
   validate the entered URLs by clicking the link below it.  This avoids failed
   jobs due to simple URL issues (e.g. non-existence of the "Input URL").  For
   examples of how to fill in this form, see the [E. coli EMR] and [Mouse
   chromosome 17 EMR] examples.

[Monitoring your EMR jobs]: #monitoring-your-emr-jobs

# Running Crossbow on EMR via the command line

## Prerequisites

1. [EC2], [S3], [EMR], and [SimpleDB] accounts.  To check which ones you've
   already enabled, visit your [Account Activity] page.
2. A tool for browsing and exchanging files with [S3]
    a. The [AWS Console]'s [S3 tab] is a good web-based tool that does not
       require software installation
    b. A good command line tool is [s3cmd]
    c. A good GUI tool is [S3Fox Organizer], which is a Firefox Plugin
    d. Others include [Cyberduck], [Bucket Explorer]
3. Basic knowledge regarding:
    a. [What S3 is], [what an S3 bucket is], how to create one, how to upload a
       file to an S3 bucket from your computer (see your S3 tool's documentation).
    b. How much AWS resources [will cost you]

[Account Activity]: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?ie=UTF8&action=activity-summary
[s3cmd]: http://s3tools.org/s3cmd
[S3Fox Organizer]: http://www.s3fox.net/
[Cyberduck]: http://cyberduck.ch/
[Bucket Explorer]: http://www.bucketexplorer.com/
[What S3 is]: http://aws.amazon.com/s3/
[What an S3 bucket is]: http://docs.amazonwebservices.com/AmazonS3/latest/gsg/
[will cost you]: http://aws.amazon.com/ec2/#pricing

## To run

1.  *If the input reads have not yet been preprocessed by Crossbow* (i.e. input
    is [FASTQ] or [`.sra`]), then first (a) prepare a [manifest file] with URLs
    pointing to the read files, and (b) upload it to an [S3] bucket that you
    own. See your [S3] tool's documentation for how to create a bucket and
    upload a file to it.  The URL for the [manifest file] will be the input URL
    for your [EMR] job.
    
    *If the input reads have already been preprocessed by Crossbow*, make a note
    of of the [S3] URL where they're located.  This will be the input URL for
    your [EMR] job.

2.  *If you are using a pre-built reference jar*, make a note of its [S3] URL. 
    This will be the reference URL for your [EMR] job.  See the [Crossbow
    website] for a list of pre-built reference jars and their URLs.
   
    *If you are not using a pre-built reference jar*, you may need to [build the
    reference jars] and/or upload them to an [S3] bucket you own.  See your [S3
    tool]'s documentation for how to create a bucket and upload to it.  The URL
    for the main reference jar will be the reference URL for your [EMR] job.

[Crossbow website]: http://bowtie-bio.sf.net/crossbow
[build the reference jars]: #reference-jars
[S3 tool]: #s3-tools

3.  Run `$CROSSBOW_HOME/cb_emr` with the desired options. Options that are unique
    to [EMR] jobs are described in the following section.  Options that apply to
    all running modes are described in the [General Crossbow options] section.
    For examples of how to run `$CROSSBOW_HOME/cb_emr` see the [E. coli EMR] and
    [Mouse chromosome 17 EMR] examples.

[General Crossbow options]: #general-crossbow-options
[E. coli EMR]: #cb-example-e-coli-emr
[Mouse chromosome 17 EMR]: #cb-example-mouse17-emr

## EMR-specific options

<table>

<tr><td id="cb-emr-reference">

[`--reference`]: #cb-emr-reference

    --reference <URL>

</td><td>

[S3] URL where the reference jar is located.  URLs for pre-built reference jars
for some commonly studied species (including human and mouse) are available from
the [Crossbow web site].  Note that a [Myrna] reference jar is not the same as a
[Crossbow] reference jar. If your desired genome and/or SNP annotations are not
available in pre-built form, you will have to make your own reference jar and
upload it to one of your own S3 buckets (see [Reference jars]).  This option
must be specified.

[Myrna]: http://bowtie-bio.sf.net/myrna
[Reference jars]: #reference-jars
[Crossbow web site]: http://bowtie-bio.sf.net/crossbow

<tr><td id="cb-emr-input">

[`--input`]: #cb-emr-input

    --input <URL>

</td><td>

[S3] URL where the input is located.  If [`--preprocess`] or
[`--just-preprocess`] are specified, `<URL>` sould point to a [manifest file]. 
Otherwise, `<URL>` should point to a directory containing preprocessed reads. 
This option must be specified.

</td></tr><tr><td id="cb-emr-output">

[`--output`]: #cb-emr-output

    --output <URL>

</td><td>

[S3] URL where the output is to be deposited.  If [`--just-preprocess`] is
specified, the output consists of the preprocessed reads. Otherwise, the output
consists of the SNP calls calculated by [SOAPsnp] for each chromosome in the
[Crossbow output format], organized as one file per chromosome.  This option
must be specified.

[Crossbow output format]: #cb-output

</td></tr><tr><td id="cb-emr-intermediate">

[`--intermediate`]: #cb-emr-intermediate

    --intermediate <URL>

</td><td>

[S3] URL where all intermediate results should be be deposited.  This can be
useful if you later want to resume the computation from partway through the
pipeline (e.g. after alignment but before SNP calling).  By default,
intermediate results are stored in [HDFS] and disappear once the cluster is
terminated.

</td></tr><tr><td id="cb-emr-preprocess-output">

[`--preprocess-output`]: #cb-emr-preprocess-output

    --preprocess-output <URL>

</td><td>

[S3] URL where the preprocessed reads should be stored.  This can be useful if
you later want to run Crossbow on the same input reads without having to re-run
the preprocessing step (i.e. leaving [`--preprocess`] unspecified).

</td></tr><tr><td id="cb-emr-credentials">

[`--credentials`]: #cb-emr-credentials

    --credentials <id>

</td><td>

Local path to the credentials file set up by the user when the
[`elastic-mapreduce`] script was installed (see [Installing Amazon's
`elastic-mapreduce` tool]).  Default: use `elastic-mapreduce`'s default (i.e.
the `credentials.json` file in the same directory as the `elastic-mapreduce`
script).  If `--credentials` is not specified and the default `credentials.json`
file doesn't exist, `elastic-mapreduce` will abort with an error message.

[Installing Amazon's `elastic-mapreduce` tool]: #installing-amazons-elastic-mapreduce-tool

</td></tr><tr><td id="cb-emr-script">

[`--emr-script`]: #cb-emr-script

    --emr-script <path>

</td><td>

Local path to the `elastic-mapreduce` script.  By default, Crossbow looks first
in the `$CROSSBOW_EMR_HOME` directory, then in the `PATH`.

</td></tr><tr><td id="cb-emr-name">

[`--name`]: #cb-emr-name

    --name <string>

</td><td>

Specify the name by which the job will be identified in the [AWS Console].

</td></tr><tr><td id="cb-emr-stay-alive">

[`--stay-alive`]: #cb-stay-alive

    --stay-alive

</td><td>

By default, [EMR] will terminate the cluster as soon as (a) one of the stages
fails, or (b) the job complete successfully.  Specify this option to force [EMR]
to keep the cluster alive in either case.

</td></tr><tr><td id="cb-emr-instances">

[`--instances`]: #cb-instances

    --instances <int>

</td><td>

Specify the number of instances (i.e. virtual computers, also called nodes) to
be allocated to your cluster.  If set to 1, the 1 instance will funcion as both
[Hadoop] master and slave node.  If set greater than 1, one instance will
function as a [Hadoop] master and the rest will function as [Hadoop] slaves.  In
general, the greater the value of `<int>`, the faster the Crossbow computation
will complete.  Consider the desired speed as well as the [going rate] when
choosing a value for `<int>`.  Default: 1.

</td></tr><tr><td id="cb-emr-instance-type">

[`--instance-type`]: #cb-instance-type

    --instance-type <type>

</td><td>

Specify the type of [EC2] instance to use for the computation.  See Amazon's
[list of available instance types] and be sure to specify the "API name" of the
desired type (e.g. `m1.small` or `c1.xlarge`).  **The default of `c1.xlarge` is
strongly recommended** because it has an appropriate mix of computing power and
memory for a large breadth of problems.  Choosing an instance type with less
than 5GB of physical RAM can cause problems when the reference is as large (e.g.
a mammalian genome).  Stick to the default unless you're pretty sure the
specified instance type can handle your problem size.

[list of available instance types]: http://aws.amazon.com/ec2/instance-types/
[`<instance-type>`]: http://aws.amazon.com/ec2/instance-types/

</td></tr><tr><td id="cb-emr-args">

[`--emr-args`]: #cb-emr-args

    --emr-args "<args>"

</td><td>

Pass the specified extra arguments to the `elastic-mapreduce` script. See
documentation for the `elastic-mapreduce` script for details.

</td></tr><tr><td id="cb-logs">

[`--logs`]: #cb-logs

    --logs <URL>

</td><td>

Causes [EMR] to copy the log files to `<URL>`.  Default: [EMR] writes logs to
the `logs` subdirectory of the [`--output`] URL.  See also [`--no-logs`].

</td></tr><tr><td id="cb-no-logs">

[`--no-logs`]: #cb-no-logs

    --no-logs

</td><td>

By default, Crossbow causes [EMR] to copy all cluster log files to the `log`
subdirectory of the [`--output`] URL (or another destination, if [`--logs`] is
specified).  Specifying this option disables all copying of logs.

</td></tr><tr><td id="cb-no-emr-debug">

[`--no-emr-debug`]: #cb-no-emr-debug

    --no-emr-debug

</td><td>

Disables [Job Flow Debugging].  If this is *not* specified, you must have a
[SimpleDB] account for [Job Flow Debugging] to work.  You will be subject to
additional [SimpleDB-related charges] if this option is enabled, but those fees
are typically small or zero (depending on your account's [SimpleDB tier]).

[Job Flow Debugging]: http://docs.amazonwebservices.com/ElasticMapReduce/latest/DeveloperGuide/DebuggingJobFlows.html
[SimpleDB]: http://aws.amazon.com/simpledb/
[SimpleDB-related charges]: http://aws.amazon.com/simpledb/#pricing
[SimpleDB tier]: http://aws.amazon.com/simpledb/#pricing

</td></tr>
</table>

# Running Crossbow on a Hadoop cluster via the command line

## Prerequisites

1. Working installation of [Hadoop] v0.20.2 or v0.20.205.  Other versions newer
   than 0.20 might also work, but haven't been tested.

2. A `bowtie` v0.12.8 executable must exist at the same path on all cluster
   nodes (including the master).  That path must be specified via the
   [`--bowtie`](#cb-hadoop-bowtie) option OR located in the directory specified
   in the `CROSSBOW_BOWTIE_HOME` environment variable, OR in a subdirectory of
   `$CROSSBOW_HOME/bin` OR in the `PATH` (Crossbow looks in that order).
   `$CROSSBOW_HOME/bin` comes with pre-built Bowtie binaries for Linux and Mac
   OS X 10.5 or later.  An executable from that directory is used automatically
   unless the platform is not Mac or Linux or unless overridden by
   [`--bowtie`](#cb-hadoop-bowtie) or by defining `CROSSBOW_BOWTIE_HOME`.

3. A Crossbow-customized version of `soapsnp` v1.02 must be installed
   at the same path on all cluster nodes (including the master).  That
   path must be specified via the [`--soapsnp`](#cb-hadoop-soapsnp) option OR located in the
   directory specified in the `CROSSBOW_SOAPSNP_HOME` environment
   variable, OR in a subdirectory of `$CROSSBOW_HOME/bin` OR in the
   `PATH` (Crossbow searches in that order). `$CROSSBOW_HOME/bin` comes
   with pre-built SOAPsnp binaries for Linux and Mac OS X 10.6 or
   later.  An executable from that directory is used automatically
   unless the platform is not Mac or Linux or unless overridden by
   [`--soapsnp`](#cb-hadoop-soapsnp) or by defining `CROSSBOW_SOAPSNP_HOME`.

4. If any of your inputs are in [Sequence Read Archive] format (i.e. end in
   `.sra`), then the `fastq-dump` tool from the [SRA Toolkit] must be installed
   at the same path on all cluster nodes.  The path to the `fastq-dump` tool
   must be specified via the ([`--fastq-dump`](#myrna-fastq-dump)) option OR
   `fastq-dump` must be located in the directory specified in the
   `CROSSBOW_FASTQ_DUMP_HOME` environment variable, OR `fastq-dump` must be
   found in the `PATH` (Myrna searches in that order).
   
5. Sufficient memory must be available on all [Hadoop] slave nodes to
   hold the Bowtie index for the desired organism in addition to any
   other loads placed on those nodes by [Hadoop] or other programs.
   For mammalian genomes such as the human genome, this typically means
   that slave nodes must have at least 5-6 GB of RAM.

## To run

Run `$CROSSBOW_HOME/cb_hadoop` with the desired options.  Options that are
unique to [Hadoop] jobs are described in the following subsection.  Options that
apply to all running modes are described in the [General Crossbow options]
subsection.  To see example invocations of `$CROSSBOW_HOME/cb_hadoop` see the
[E. coli Hadoop] and [Mouse chromosome 17 Hadoop] examples.

[General Crossbow options]: #general-crossbow-options
[E. coli Hadoop]: #cb-example-e-coli-hadoop
[Mouse chromosome 17 Hadoop]: #cb-example-mouse17-hadoop

## Hadoop-specific options

<table>

<tr><td id="cb-hadoop-reference">

[`--reference`]: #cb-hadoop-reference

    --reference <URL>

</td><td>

[HDFS] URL where the reference jar is located.  Pre-built reference jars for
some commonly studied species (including human and mouse) are available from the
[Crossbow web site]; these can be downloaded and installed in HDFS using `hadoop
dfs` commands.  If your desired genome and/or SNP annotations are not available
in pre-built form, you will have to make your own reference jars, install them
in HDFS, and specify their HDFS path here.  This option must be specified.

[Crossbow web site]: http://bowtie-bio.sf.net/crossbow
[HDFS]: http://hadoop.apache.org/common/docs/current/hdfs_design.html

<tr><td id="cb-hadoop-input">

[`--input`]: #cb-hadoop-input

    --input <URL>

</td><td>

[HDFS] URL where the input is located.  If [`--preprocess`] or
[`--just-preprocess`] are specified, `<URL>` sould point to a manifest file. 
Otherwise, `<URL>` should point to a directory containing preprocessed reads. 
This option must be specified.

</td></tr><tr><td id="cb-hadoop-output">

[`--output`]: #cb-hadoop-output

    --output <URL>

</td><td>

[HDFS] URL where the output is to be deposited.  If [`--just-preprocess`] is
specified, the output consists of the preprocessed reads. Otherwise, the output
consists of the SNP calls calculated by SOAPsnp for each chromosome, organized
as one file per chromosome.  This option must be specified.

</td></tr><tr><td id="cb-hadoop-intermediate">

[`--intermediate`]: #cb-hadoop-intermediate

    --intermediate <URL>

</td><td>

[HDFS] URL where all intermediate results should be be deposited. Default:
`hdfs:///crossbow/intermediate/<PID>`.

</td></tr><tr><td id="cb-hadoop-preprocess-output">

[`--preprocess-output`]: #cb-hadoop-preprocess-output

    --preprocess-output <URL>

</td><td>

[HDFS] URL where the preprocessed reads should be stored.  This can be useful if
you later want to run Crossbow on the same input reads without having to re-run
the preprocessing step (i.e. leaving [`--preprocess`] unspecified).

</td></tr><tr><td id="cb-hadoop-bowtie">

[`--bowtie`]: #cb-hadoop-bowtie

    --bowtie <path>

</td><td>

Local path to the [Bowtie] binary Crossbow should use.  `bowtie` must be
installed in this same directory on all [Hadoop] worker nodes.  By default,
Crossbow searches the `PATH` and in the directory pointed to by the
`CROSSBOW_HOME` environment variable.

</td></tr><tr><td id="cb-hadoop-fastq-dump">

[`--fastq-dump`]: #cb-hadoop-fastq-dump

    --fastq-dump <path>

</td><td>

Path to the directory containing `fastq-dump`, which is part of the [SRA
Toolkit].  This overrides all other ways that Crossbow searches for
`fastq-dump`, including the `CROSSBOW_SRATOOLKIT_HOME` environment variable, the
subdirectories of the `$CROSSBOW_HOME/bin` directory, and the `PATH`.

</td></tr><tr><td id="cb-hadoop-soapsnp">

[`--soapsnp`]: #cb-hadoop-soapsnp

    --soapsnp <path>

</td><td>

Local path to the SOAPsnp executable to use when running the Call SNPs step. 
`soapsnp` must be installed in this same directory on all [Hadoop] worker nodes 
This overrides all other ways that Crossbow searches for `soapsnp`, including
the `CROSSBOW_SOAPSNP_HOME` environment variable, the subdirectories of the
`$CROSSBOW_HOME/bin` directory, and the `PATH`.

</td></tr>
</table>

# Running Crossbow on a single computer via the command line

## Prerequisites

1. A `bowtie` v0.12.8 executable must exist on the local computer.  The
   path to `bowtie` must be specified via the [`--bowtie`](#cb-local-bowtie) option OR be located
   in the directory specified in the `$CROSSBOW_BOWTIE_HOME` environment
   variable, OR in a subdirectory of `$CROSSBOW_HOME/bin` OR in the `PATH`
   (search proceeds in that order).  `$CROSSBOW_HOME/bin` comes with
   pre-built Bowtie binaries for Linux and Mac OS X 10.6 or later, so most
   Mac and Linux users do not need to install either tool.

2. A Crossbow-customized version of `soapsnp` v1.02 must exist.  The path
   to `soapsnp` must be specified via the [`--soapsnp`](#cb-local-soapsnp) option OR be in
   the directory specified in the `$CROSSBOW_SOAPSNP_HOME` environment
   variable, OR in a subdirectory of `$CROSSBOW_HOME/bin` OR in the `PATH` (Crossbow searches in that order).
   `$CROSSBOW_HOME/bin` comes with pre-built SOAPsnp binaries for Linux and
   Mac OS X 10.6 or later.  An executable from that directory is used
   automatically unless the platform is not Mac or Linux or unless
   overridden by [`--soapsnp`](#cb-local-soapsnp) or `$CROSSBOW_SOAPSNP_HOME`.

3. If any of your inputs are in [Sequence Read Archive] format (i.e. end in
   `.sra`), then the `fastq-dump` tool from the [SRA Toolkit] must be installed
   on the local computer.  The path to the `fastq-dump` tool must be specified
   via the ([`--fastq-dump`](#myrna-fastq-dump)) option OR `fastq-dump` must be
   located in the directory specified in the `MYRNA_FASTQ_DUMP_HOME` environment
   variable, OR `fastq-dump` must be found in the `PATH` (Myrna searches in that
   order).

4. Sufficient memory must be available on the local computer to hold one copy of
   the Bowtie index for the desired organism *in addition* to all other running
   workloads.  For mammalian genomes such as the human genome, this typically
   means that the local computer must have at least 5-6 GB of RAM.

## To run

Run `$CROSSBOW_HOME/cb_local` with the desired options.  Options unique to local
jobs are described in the following subsection.  Options that apply to all
running modes are described in the [General Crossbow options] subsection.  To
see example invocations of `$CROSSBOW_HOME/cb_local` see the [E. coli local] and
[Mouse chromosome 17 local] examples.

[General Crossbow options]: #general-crossbow-options
[E. coli local]: #cb-example-e-coli-local
[Mouse chromosome 17 local]: #cb-example-mouse17-local

## Local-run-specific options

<table>

<tr><td id="cb-local-reference">

[`--reference`]: #cb-local-reference

    --reference <path>

</td><td>

Local path where expanded reference jar is located.  Specified path should have
a `index` subdirectory with a set of Bowtie index files, a `sequences`
subdirectory with a set of FASTA files, a `snps` subdirectory with 0 or more
per-chromosome SNP description files, and a `cmap.txt` file.  Pre-built
reference jars for some commonly studied species (including human and mouse) are
available from the [Crossbow web site]; these can be downloaded and expanded
into a directory with the appropriate structure using an [`unzip`] utility.  If
your desired genome and/or SNP annotations are not available in pre-built form,
you will have to make your own reference jars and specify the appropriate path. 
This option must be specified.

[Crossbow web site]: http://bowtie-bio.sf.net/crossbow
[HDFS]: http://hadoop.apache.org/common/docs/current/hdfs_design.html
[`unzip`]: http://en.wikipedia.org/wiki/Unzip

<tr><td id="cb-local-input">

[`--input`]: #cb-local-input

    --input <path>

</td><td>

Local path where the input is located.  If [`--preprocess`] or
[`--just-preprocess`] are specified, this sould point to a [manifest file]. 
Otherwise, this should point to a directory containing preprocessed reads.  This
option must be specified.

</td></tr><tr><td id="cb-local-output">

[`--output`]: #cb-local-output

    --output <path>

</td><td>

Local path where the output is to be deposited.  If [`--just-preprocess`] is
specified, the output consists of the preprocessed reads.  Otherwise, the output
consists of the SNP calls calculated by SOAPsnp for each chromosome, organized
as one file per chromosome.  This option must be specified.

</td></tr><tr><td id="cb-local-intermediate">

[`--intermediate`]: #cb-local-intermediate

    --intermediate <path>

</td><td>

Local path where all intermediate results should be kept temporarily (or
permanently, if [`--keep-intermediates`] or [`--keep-all`] are specified). 
Default: `/tmp/crossbow/intermediate/<PID>`.

</td></tr><tr><td id="cb-local-preprocess-output">

[`--preprocess-output`]: #cb-local-preprocess-output

    --preprocess-output <path>

</td><td>

Local path where the preprocessed reads should be stored.  This can be useful if
you later want to run Crossbow on the same input reads without having to re-run
the preprocessing step (i.e. leaving [`--preprocess`] unspecified).

</td></tr><tr><td id="cb-local-keep-intermediates">

[`--keep-intermediates`]: #cb-local-keep-intermediates

    --keep-intermediates

</td><td>

Keep intermediate directories and files, i.e. the output from all stages prior
to the final stage.  By default these files are deleted as soon as possible.

</td></tr><tr><td id="cb-local-keep-all">

[`--keep-all`]: #cb-local-keep-all

    --keep-all

</td><td>

Keep all temporary files generated during the process of binning and sorting
data records and moving them from stage to stage, as well as all intermediate
results.  By default these files are deleted as soon as possible.

</td></tr><tr><td id="cb-local-cpus">

[`--cpus`]: #cb-local-cpus

    --cpus <int>

</td><td>

The maximum number of processors to use at any given time during the job. 
Crossbow will try to make maximal use of the processors allocated.  Default: 1.

</td></tr><tr><td id="cb-local-max-sort-records">

[`--max-sort-records`]: #cb-local-max-sort-records

    --max-sort-records <int>

</td><td>

Maximum number of records to be dispatched to the sort routine at one time when
sorting bins before each reduce step.  For each child process, this number is
effectively divided by the number of CPUs used ([`--cpus`]).  The default is
200000.

</td></tr><tr><td id="cb-local-max-sort-files">

[`--max-sort-files`]: #cb-local-max-sort-files

    --max-sort-files <int>

</td><td>

Maximum number of files that can be opened at once by the sort routine when
sorting bins before each reduce step.  For each child process, this number is
effectively divided by the number of CPUs used ([`--cpus`]).  The default is 40.

</td></tr><tr><td id="cb-local-bowtie">

[`--bowtie`]: #cb-local-bowtie

    --bowtie <path>

</td><td>

Path to the Bowtie executable to use when running the Align step.  This
overrides all other ways that Crossbow searches for `bowtie`, including the
`CROSSBOW_BOWTIE_HOME` environment variable, the subdirectories of the
`$CROSSBOW_HOME/bin` directory, and the `PATH`.

</td></tr><tr><td id="cb-local-fastq-dump">

[`--fastq-dump`]: #cb-local-fastq-dump

    --fastq-dump <path>

</td><td>

Path to the directory containing the programs in the [SRA toolkit], including
`fastq-dump`.  This overrides all other ways that Crossbow searches for
`fastq-dump`, including the `CROSSBOW_SRATOOLKIT_HOME` environment variable, the
subdirectories of the `$CROSSBOW_HOME/bin` directory, and the `PATH`.

</td></tr><tr><td id="cb-local-soapsnp">

[`--soapsnp`]: #cb-local-soapsnp

    --soapsnp <path>

</td><td>

Path to the SOAPsnp executable to use when running the Call SNPs step. This
overrides all other ways that Crossbow searches for `soapsnp`, including the
`CROSSBOW_SOAPSNP_HOME` environment variable, the subdirectories of the
`$CROSSBOW_HOME/bin` directory, and the `PATH`.

</td></tr>

</table>

# General Crossbow options

The following options can be specified regardless of what mode ([EMR],
[Hadoop] or local) Crossbow is run in.

<table>

<tr><td id="cb-quality">

[`--quality`]: #cb-quality

    --quality { phred33 | phred64 | solexa64 }

</td><td>

Treat all input reads as having the specified quality encoding. `phred33`
denotes the [Phred+33] or "Sanger" format whereby ASCII values 33-126 are used
to encode qualities on the [Phred scale]. `phred64` denotes the [Phred+64] or
"Illumina 1.3+" format whereby ASCII values 64-126 are used to encode qualities
on the [Phred scale]. `solexa64` denotes the [Solexa+64] or "Solexa/Illumina
1.0" format whereby ASCII values 59-126 are used to encode qualities on a
[log-odds scale] that includes values as low as -5.  Default: `phred33`.

[Phred scale]: http://en.wikipedia.org/wiki/Phred_quality_score
[Phred+33]: http://en.wikipedia.org/wiki/FASTQ_format#Encoding
[Phred+64]: http://en.wikipedia.org/wiki/FASTQ_format#Encoding
[Solexa+64]: http://en.wikipedia.org/wiki/FASTQ_format#Encoding
[log-odds scale]: http://en.wikipedia.org/wiki/FASTQ_format#Variations

</td></tr><tr><td id="cb-preprocess">

[`--preprocess`]: #cb-preprocess

    --preprocess

</td><td>

The input path or URL refers to a [manifest file] rather than a directory of
preprocessed reads.  The first step in the Crossbow computation will be to
preprocess the reads listed in the [manifest file] and store the preprocessed
reads in the intermediate directory or in the `--preprocess-output` directory if
it's specified.  Default: off.

[manifest file]: #manifest-files

</td></tr><tr><td id="cb-just-preprocess">

[`--just-preprocess`]: #cb-just-preprocess

    --just-preprocess

</td><td>

The input path or URL refers to a [manifest file] rather than a directory of
preprocessed reads.  Crossbow will preprocess the reads listed in the [manifest
file] and store the preprocessed reads in the `--output` directory and quit. 
Default: off.

[manifest file]: #manifest-files

</td></tr><tr><td id="cb-just-align">

[`--just-align`]: #cb-just-align

    --just-align

</td><td>

Instead of running the Crossbow pipeline all the way through to the end, run the
pipeline up to and including the align stage and store the results in the
[`--output`] URL.  To resume the run later, use [`--resume-align`].

</td></tr><tr><td id="cb-resume-align">

[`--resume-align`]: #cb-resume-align

    --resume-align

</td><td>

Resume the Crossbow pipeline from just after the alignment stage.  The
[`--input`] URL must point to an [`--output`] URL from a previous run using
[`--just-align`].

</td></tr><tr><td id="cb-bowtie-args">

[`--bowtie-args`]: #cb-bowtie-args

    --bowtie-args "<args>"

</td><td>

Pass the specified arguments to [Bowtie] for the Align stage.  Default: [`-M
1`].  See the [Bowtie manual] for details on what options are available.

[`-M 1`]: http://bowtie-bio.sf.net/manual.shtml#bowtie-options-M
[Bowtie manual]: http://bowtie-bio.sf.net/manual.shtml

</td></tr><tr><td id="cb-discard-reads">

[`--discard-reads`]: #cb-discard-reads

    --discard-reads <fraction>

</td><td>

Randomly discard a fraction of the input reads.  E.g. specify `0.5` to discard
50%.  This applies to all input reads regardless of type (paired vs. unpaired)
or length.  This can be useful for debugging. Default: 0.0.

</td></tr><tr><td id="cb-discard-ref-bins">

[`--discard-ref-bins`]: #cb-discard-ref-bins

    --discard-ref-bins <fraction>

</td><td>

Randomly discard a fraction of the reference bins prior to SNP calling. E.g.
specify `0.5` to discard 50% of the reference bins.  This can be useful for
debugging.  Default: 0.0.

</td></tr><tr><td id="cb-discard-all">

[`--discard-all`]: #cb-discard-all

    --discard-all <fraction>

</td><td>

Equivalent to setting [`--discard-reads`] and [`--discard-ref-bins`] to
`<fraction>`.  Default: 0.0.

</td></tr><tr><td id="cb-soapsnp-args">

[`--soapsnp-args`]: #cb-soapsnp-args

    --soapsnp-args "<args>"

</td><td>

Pass the specified arguments to [SOAPsnp] in the SNP calling stage. These
options are passed to SOAPsnp regardless of whether the reference sequence under
consideration is diploid or haploid.  Default: `-2 -u -n -q`.  See the [SOAPsnp
manual] for details on what options are available.

[SOAPsnp manual]: http://soap.genomics.org.cn/soapsnp.html

</td></tr><tr><td id="cb-soapsnp-hap-args">

[`--soapsnp-hap-args`]: #cb-soapsnp-hap-args

    --soapsnp-hap-args "<args>"

</td><td>

Pass the specified arguments to [SOAPsnp] in the SNP calling stage. when the
reference sequence under consideration is haploid.   Default: `-r 0.0001`.  See
the [SOAPsnp manual] for details on what options are available.

</td></tr><tr><td id="cb-soapsnp-dip-args">

[`--soapsnp-dip-args`]: #cb-soapsnp-dip-args

    --soapsnp-dip-args "<args>"

</td><td>

Pass the specified arguments to [SOAPsnp] in the SNP calling stage. when the
reference sequence under consideration is diploid.   Default: `-r 0.00005 -e
0.0001`.  See the [SOAPsnp manual] for details on what options are available.

</td></tr><tr><td id="cb-haploids">

[`--haploids`]: #cb-haploids

    --haploids <chromosome-list>

</td><td>

The specified comma-separated list of chromosome names are to be treated as
haploid by SOAPsnp.  The rest are treated as diploid. Default: all chromosomes
are treated as diploid.

</td></tr><tr><td id="cb-all-haploids">

[`--all-haploids`]: #cb-all-haploids

    --all-haploids

</td><td>

If specified, all chromosomes are treated as haploid by SOAPsnp.

</td></tr><tr><td id="cb-partition-len">

[`--partition-len`]: #cb-partition-len

    --partition-len <int>

</td><td>

The bin size to use when binning alignments into partitions prior to SNP
calling.  If load imbalance occurrs in the SNP calling step (some tasks taking
far longer than others), try decreasing this.  Default: 1,000,000.

></tr><tr><td id="cb-dry-run">

[`--dry-run`]: #cb-dry-run

    --dry-run

</td><td>

Just generate a script containing the commands needed to launch the job, but
don't run it.  The script's location will be printed so that you may run it
later.

</td></tr>

</td></tr><tr><td id="cb-test">

[`--test`]: #cb-test

    --test

</td><td>

Instead of running Crossbow, just search for the supporting tools ([Bowtie] and
[SOAPsnp]) and report whether and how they were found. If running in Cloud Mode,
this just tests whether the `elastic-mapreduce` script is locatable and
runnable. Use this option to debug your local Crossbow installation.

</td></tr><tr><td id="cb-tempdir">

[`--tempdir`]: #cb-tempdir

    --tempdir `<path>`

</td><td>

Local directory where temporary files (e.g. dynamically generated scripts)
should be deposited.  Default: `/tmp/Crossbow/invoke.scripts`.

</td></tr>
</table>

# Crossbow examples

The following subsections guide you step-by-step through examples included with
the Crossbow package.  Because reads (and sometimes reference jars) must be
obtained over the Internet, running these examples requires an active Internet
connection.

## E. coli (small)

Data for this example is taken from the study by [Parkhomchuk et al].

[Parkhomchuk et al]: http://www.pnas.org/content/early/2009/11/19/0906681106.abstract

### EMR

<div id="cb-example-e-coli-emr" />

#### Via web interface

Identify an [S3] bucket to hold the job's input and output.  You may
need to create an [S3 bucket] for this purpose.  See your [S3 tool]'s
documentation.

[S3 tool]: #s3-tools
[S3 bucket]: http://docs.amazonwebservices.com/AmazonS3/latest/index.html?UsingBucket.html

Use an [S3 tool] to upload `$CROSSBOW_HOME/example/e_coli/small.manifest` to
the `example/e_coli` subdirectory in your bucket.  You can do so with this
[s3cmd] command:

    s3cmd put $CROSSBOW_HOME/example/e_coli/small.manifest s3://<YOUR-BUCKET>/example/e_coli/

Direct your web browser to the [Crossbow web interface] and fill in the form as
below (substituting for `<YOUR-BUCKET>`):

<div>
<img src="images/AWS_cb_e_coli_fillin.png" alt="" />
<p><i>Crossbow web form filled in for the small E. coli example.</i></p>
</div>

1.  For **AWS ID**, enter your AWS Access Key ID
2.  For **AWS Secret Key**, enter your AWS Secret Access Key
3.  *Optional*: For **AWS Keypair name**, enter the name of
    your AWS keypair.  This is only necessary if you would like to be
    able to [ssh] into the [EMR] cluster while it runs.
4.  *Optional*: Check that the AWS ID and Secret Key entered are
    valid by clicking the "Check credentials..." link
5.  For **Job name**, enter `Crossbow-Ecoli`
6.  Make sure that **Job type** is set to "Crossbow"
7.  For **Input URL**, enter
    `s3n://<YOUR-BUCKET>/example/e_coli/small.manifest`, substituting
    for `<YOUR-BUCKET>`
8.  *Optional*: Check that the Input URL exists by clicking the
    "Check that input URL exists..." link
9.  For **Output URL**, enter
    `s3n://<YOUR-BUCKET>/example/e_coli/output_small`, substituting for
    `<YOUR-BUCKET>`
10. *Optional*: Check that the Output URL does not exist by
    clicking the "Check that output URL doesn't exist..." link
11. For **Input type**, select "Manifest file"
12. For **Genome/Annotation**, select "E. coli" from the drop-down
    menu
13. For **Chromosome ploidy**, select "All are haploid"
14. Click Submit

This job typically takes about 30 minutes on 1 `c1.xlarge` [EC2] node. See
[Monitoring your EMR jobs] for information on how to track job progress.  To
download the results, use an [S3 tool] to retrieve the contents of the
`s3n://<YOUR-BUCKET>/example/e_coli/output_small` directory.

[ssh]: http://en.wikipedia.org/wiki/Secure_Shell

#### Via command line

Test your Crossbow installation by running:

    $CROSSBOW_HOME/cb_emr --test

This will warn you if any supporting tools (`elastic-mapreduce` in this case)
cannot be located or run.

Identify an [S3] bucket to hold the job's input and output.  You may need to
create an [S3 bucket] for this purpose.  See your [S3 tool]'s documentation.

[S3 tool]: #s3-tools

Use your [S3 tool] to upload `$CROSSBOW_HOME/example/e_coli/small.manifest` to
the `example/e_coli` subdirectory in your bucket.  You can do so with this
[s3cmd] command:

    s3cmd put $CROSSBOW_HOME/example/e_coli/small.manifest s3://<YOUR-BUCKET>/example/e_coli/

Start the [EMR] job with the following command (substituting for
`<YOUR-BUCKET>`):

    $CROSSBOW_HOME/cb_emr \
        --name "Crossbow-Ecoli" \
        --preprocess \
        --input=s3n://<YOUR-BUCKET>/example/e_coli/small.manifest \
        --output=s3n://<YOUR-BUCKET>/example/e_coli/output_small \
        --reference=s3n://crossbow-refs/e_coli.jar \
        --all-haploids

The `--reference` option instructs Crossbow to use a pre-built reference jar at
URL `s3n://crossbow-refs/e_coli.jar`.  The [`--preprocess`] option instructs
Crossbow to treat the input as a [manifest file], rather than a directory of
already-preprocessed reads.  As the first stage of the pipeline, Crossbow
downloads files specified in the manifest file and preprocesses them into
Crossbow's read format.  [`--output`] specifies where the final output is placed.

This job typically takes about 30 minutes on 1 `c1.xlarge` [EC2] node. See
[Monitoring your EMR jobs] for information on how to track job progress.  To
download the results, use an [S3 tool] to retrieve the contents of the
`s3n://<YOUR-BUCKET>/example/e_coli/output_small` directory.

[Monitoring your EMR jobs]: #monitoring-your-emr-jobs

### Hadoop

<div id="cb-example-e-coli-hadoop" />

Log into the [Hadoop] master node and test your Crossbow installation by running:

    $CROSSBOW_HOME/cb_hadoop --test

This will tell you if any of the supporting tools or packages are missing on the
master.  *You must also ensure* that the same tools are installed in the same
paths on all slave nodes, and are runnable by the slaves.

From the master, download the file named `e_coli.jar` from the following URL:

    http://crossbow-refs.s3.amazonaws.com/e_coli.jar

E.g. with this command:

    wget http://crossbow-refs.s3.amazonaws.com/e_coli.jar

Equivalently, you can use an [S3 tool] to download the same file from this URL:

    s3n://crossbow-refs/e_coli.jar

E.g. with this [s3cmd] command:

    s3cmd get s3://crossbow-refs/e_coli.jar

Install `e_coli.jar` in [HDFS] (the [Hadoop] distributed filesystem) with the
following commands.  If the `hadoop` script is not in your `PATH`, either add it
to your `PATH` (recommended) or specify the full path to the `hadoop` script in
the following commands.

    hadoop dfs -mkdir /crossbow-refs
    hadoop dfs -put e_coli.jar /crossbow-refs/e_coli.jar

The first creates a directory in [HDFS] (you will see a warning message if the
directory already exists) and the second copies the local jar files into that
directory.  In this example, we deposit the jars in the `/crossbow-refs`
directory, but any [HDFS] directory is fine.

Remove the local `e_coli.jar` file to save space.  E.g.:

    rm -f e_coli.jar

Next install the [manifest file] in [HDFS]:

    hadoop dfs -mkdir /crossbow/example/e_coli
    hadoop dfs -put $CROSSBOW_HOME/example/e_coli/small.manifest /crossbow/example/e_coli/small.manifest

Now start the job by running:

    $CROSSBOW_HOME/cb_hadoop \
        --preprocess \
        --input=hdfs:///crossbow/example/e_coli/small.manifest \
        --output=hdfs:///crossbow/example/e_coli/output_small \
        --reference=hdfs:///crossbow-refs/e_coli.jar \
        --all-haploids

The [`--preprocess`] option instructs Crossbow to treat the input as a [manifest
file].  As the first stage of the pipeline, Crossbow will download the files
specified on each line of the manifest file and preprocess them into Crossbow's
read format.  The [`--reference`] option specifies the location of the reference
jar contents.  The [`--output`] option specifies where the final output is
placed.

### Single computer

<div id="cb-example-e-coli-local" />

Test your Crossbow installation by running:

    $CROSSBOW_HOME/cb_local --test

This will warn you if any supporting tools (`bowtie` and `soapsnp` in this case)
cannot be located or run.

If you don't already have a `CROSSBOW_REFS` directory, choose one; it will be
the default path Crossbow searches for reference jars. Permanently set the
`CROSSBOW_REFS` environment variable to the selected directory.

Create a subdirectory called `$CROSSBOW_REFS/e_coli`:

    mkdir $CROSSBOW_REFS/e_coli

Download `e_coli.jar` from the following URL to the new `e_coli` directory:

    http://crossbow-refs.s3.amazonaws.com/e_coli.jar

E.g. with this command:

    wget -O $CROSSBOW_REFS/e_coli/e_coli.jar http://crossbow-refs.s3.amazonaws.com/e_coli.jar

Equivalently, you can use an [S3 tool] to download the same file from this URL:

    s3n://crossbow-refs/e_coli.jar

E.g. with this [s3cmd] command:

    s3cmd get s3://crossbow-refs/e_coli.jar $CROSSBOW_REFS/e_coli/e_coli.jar

Change to the new `e_coli` directory and expand `e_coli.jar` using an `unzip` or
`jar` utility:

    cd $CROSSBOW_REFS/e_coli && unzip e_coli.jar

Now you may remove `e_coli.jar` to save space:

    rm -f $CROSSBOW_REFS/e_coli/e_coli.jar

Now run Crossbow.  Change to the `$CROSSBOW_HOME/example/e_coli` directory and
start the job via the `cb_local` script:

    cd $CROSSBOW_HOME/example/e_coli
    $CROSSBOW_HOME/cb_local \
        --input=small.manifest \
        --preprocess \
        --reference=$CROSSBOW_REFS/e_coli \
        --output=output_small \
        --all-haploids \
        --cpus=<CPUS>

Substitute the number of CPUs you'd like to use for `<CPUS>`.

The [`--preprocess`] option instructs Crossbow to treat the input as a [manifest
file].  As the first stage of the pipeline, Crossbow will download the files
specified on each line of the manifest file and "preprocess" them into a format
understood by Crossbow.  The [`--reference`] option specifies the location of
the reference jar contents.  The [`--output`] option specifies where the final
output is placed.  The [`--cpus`] option enables Crossbow to use up to the
specified number of CPUs at any given time.

[manifest file]: #manifest-files

## Mouse chromosome 17 (large)

Data for this example is taken from the study by [Sudbury, Stalker et al].

[Sudbury, Stalker et al]: http://genomebiology.com/2009/10/10/R112

### EMR

<div id="cb-example-mouse17-emr" />

#### Via web interface

First we build a reference jar for a human assembly and annotations using
scripts included with Crossbow.  The script searches for a `bowtie-build`
executable with the same rules Crossbow uses to search for `bowtie`.  See
[Installing Crossbow] for details.  Because one of the steps executed by the
script builds an index of the human genome, it should be run on a computer with
plenty of memory (at least 4 gigabytes, preferably 6 or more).

    cd $CROSSBOW_HOME/reftools
    ./mm9_chr17_jar

The `mm9_chr17_jar` script will automatically:

1. Download the FASTA sequence for mouse (build [mm9]) chromome 17 from [UCSC].
2. Build an index from that FASTA sequence.
3. Download the known SNPs and SNP frequencies for mouse chromosome 17 from
   [dbSNP].
4. Arrange this information in the directory structure expected by Crossbow.
5. Package the information in a [jar file] named `mm9_chr17.jar`.

[mm9]: http://hgdownload.cse.ucsc.edu/downloads.html#mouse

Next, use an [S3 tool] to upload the `mm9_chr17.jar` file to the `crossbow-refs`
subdirectory in your bucket.  E.g. with this [s3cmd] command (substituting for
`<YOUR-BUCKET>`):

    s3cmd put $CROSSBOW_HOME/reftools/mm9_chr17/mm9_chr17.jar s3://<YOUR-BUCKET>/crossbow-refs/

[S3 tool]: #s3-tools

You may wish to remove the locally-generated reference jar files to save space.
E.g.:

    rm -rf $CROSSBOW_HOME/reftools/mm9_chr17

Use an [S3 tool] to upload `$CROSSBOW_HOME/example/mouse17/full.manifest` to the
`example/mouse17` subdirectory in your bucket.  E.g. with this [s3cmd] command:

    s3cmd put $CROSSBOW_HOME/example/mouse17/full.manifest s3://<YOUR-BUCKET>/example/mouse17/

Direct your web browser to the [Crossbow web interface] and fill in the form as
below (substituting for `<YOUR-BUCKET>`):

<div>
<img src="images/AWS_cb_mouse17_fillin.png" alt="" />
<p><i>Crossbow web form filled in for the large Mouse Chromosome 17 example.</i></p>
</div>

1.  For **AWS ID**, enter your AWS Access Key ID
2.  For **AWS Secret Key**, enter your AWS Secret Access Key
3.  *Optional*: For **AWS Keypair name**, enter the name of your AWS keypair. 
    This is only necessary if you would like to be able to [ssh] into the [EMR]
    cluster while it runs.
4.  *Optional*: Check that the AWS ID and Secret Key entered are valid by
    clicking the "Check credentials..." link
5.  For **Job name**, enter `Crossbow-Mouse17`
6.  Make sure that **Job type** is set to "Crossbow"
7.  For **Input URL**, enter
    `s3n://<YOUR-BUCKET>/example/mouse17/full.manifest`, substituting for
    `<YOUR-BUCKET>`
8.  *Optional*: Check that the Input URL exists by clicking the "Check that
    input URL exists..." link
9.  For **Output URL**, enter `s3n://<YOUR-BUCKET>/example/mouse17/output_full`,
    substituting for `<YOUR-BUCKET>`
10. *Optional*: Check that the Output URL does not exist by clicking the "Check
    that output URL doesn't exist..." link
11. For **Input type**, select "Manifest file"
12. For **Genome/Annotation**, check the box labeled "Specify reference jar
    URL:" and enter `s3n://<YOUR-BUCKET>/crossbow-refs/mm9_chr17.jar` in the
    text box below
13. *Optional*: Check that the reference jar URL exists by clicking the "Check
    that reference jar URL exists..." link
14. For **Chromosome ploidy**, select "All are diploid"
15. Click Submit

This job typically takes about 45 minutes on 8 `c1.xlarge` [EC2] instances.  See
[Monitoring your EMR jobs] for information on how to track job progress.  To
download the results, use an [S3 tool] to retrieve the contents of the
`s3n://<YOUR-BUCKET>/example/mouse17/output_full` directory.

[Monitoring your EMR jobs]: #monitoring-your-emr-jobs
[Job Flow Debugging]: http://docs.amazonwebservices.com/ElasticMapReduce/latest/DeveloperGuide/DebuggingJobFlows.html
[ssh]: http://en.wikipedia.org/wiki/Secure_Shell

#### Via command line

First we build a reference jar for a human assembly and annotations using
scripts included with Crossbow.  The script searches for a `bowtie-build`
executable with the same rules Crossbow uses to search for `bowtie`.  See
[Installing Crossbow] for details.  Because one of the steps executed by the
script builds an index of the human genome, it should be run on a computer with
plenty of memory (at least 4 gigabytes, preferably 6 or more).

    cd $CROSSBOW_HOME/reftools
    ./mm9_chr17_jar

The `mm9_chr17_jar` script will automatically:

1. Download the FASTA sequence for mouse (build [mm9]) chromome 17 from [UCSC].
2. Build an index from that FASTA sequence.
3. Download the known SNPs and SNP frequencies for mouse chromosome 17 from
   [dbSNP].
4. Arrange this information in the directory structure expected by Crossbow.
5. Package the information in a [jar file] named `mm9_chr17.jar`.

[mm9]: http://hgdownload.cse.ucsc.edu/downloads.html#mouse

Next, use an [S3 tool] to upload the `mm9_chr17.jar` file to the `crossbow-refs`
subdirectory in your bucket.  E.g. with this [s3cmd] command (substituting for
`<YOUR-BUCKET>`):

    s3cmd put $CROSSBOW_HOME/reftools/mm9_chr17/mm9_chr17.jar s3://<YOUR-BUCKET>/crossbow-refs/

[S3 tool]: #s3-tools

You may wish to remove the locally-generated reference jar files to save space.
E.g.:

    rm -rf $CROSSBOW_HOME/reftools/mm9_chr17

Use an [S3 tool] to upload `$CROSSBOW_HOME/example/mouse17/full.manifest` to the
`example/mouse17` subdirectory in your bucket.  E.g. with this [s3cmd] command:

    s3cmd put $CROSSBOW_HOME/example/mouse17/full.manifest s3://<YOUR-BUCKET>/example/mouse17/

To start the [EMR] job, run the following command (substituting for
`<YOUR-BUCKET>`):

    $CROSSBOW_HOME/cb_emr \
        --name "Crossbow-Mouse17" \
        --preprocess \
        --input=s3n://<YOUR-BUCKET>/example/mouse17/full.manifest \
        --output=s3n://<YOUR-BUCKET>/example/mouse17/output_full \
        --reference=s3n://<YOUR-BUCKET>/crossbow-refs/mm9_chr17.jar \
        --instances 8

This job typically takes about 45 minutes on 8 `c1.xlarge` [EC2] instances.  See
[Monitoring your EMR jobs] for information on how to track job progress.  To
download the results, use an [S3 tool] to retrieve the contents of the
`s3n://<YOUR-BUCKET>/example/mouse17/output_full` directory.

[Monitoring your EMR jobs]: #monitoring-your-emr-jobs
[Job Flow Debugging]: http://docs.amazonwebservices.com/ElasticMapReduce/latest/DeveloperGuide/DebuggingJobFlows.html

### Hadoop

<div id="cb-example-mouse17-hadoop" />

First we build a reference jar for a human assembly and annotations using
scripts included with Crossbow.  The script searches for a `bowtie-build`
executable with the same rules Crossbow uses to search for `bowtie`.  See
[Installing Crossbow] for details.  Because one of the steps executed by the
script builds an index of the human genome, it should be run on a computer with
plenty of memory (at least 4 gigabytes, preferably 6 or more).

    cd $CROSSBOW_HOME/reftools
    ./mm9_chr17_jar

The `mm9_chr17_jar` script will automatically:

1. Download the FASTA sequence for mouse (build [mm9]) chromome 17 from [UCSC].
2. Build an index from that FASTA sequence.
3. Download the known SNPs and SNP frequencies for mouse chromosome 17 from
   [dbSNP].
4. Arrange this information in the directory structure expected by Crossbow.
5. Package the information in a [jar file] named `mm9_chr17.jar`.

Next, use the `hadoop` script to put the `mm9_chr17.jar` file in the
`crossbow-refs` [HDFS] directory.  Note tha tif `hadoop` is not in your `PATH`,
you must specify `hadoop`'s full path instead:

    hadoop dfs -mkdir /crossbow-refs
    hadoop dfs -put $CROSSBOW_HOME/reftools/mm9_chr17/mm9_chr17.jar /crossbow-refs/mm9_chr17.jar

The first command will yield a warning if the directory already exists; ignore
this.  In this example, we deposit the jars in the `/crossbow-refs` directory,
but any [HDFS] directory is fine.

You may wish to remove the locally-generated reference jar files to save space. 
E.g.:

    rm -rf $CROSSBOW_HOME/reftools/mm9_chr17

Now install the [manifest file] in [HDFS]:

[manifest file]: #manifest-files

    hadoop dfs -mkdir /crossbow/example/mouse17
    hadoop dfs -put $CROSSBOW_HOME/example/mouse17/full.manifest /crossbow/example/mouse17/full.manifest

To start the [Hadoop] job, run the following command (substituting for
`<YOUR-BUCKET>`):

    $CROSSBOW_HOME/cb_hadoop \
        --preprocess \
        --input=hdfs:///crossbow/example/mouse17/full.manifest \
        --output=hdfs:///crossbow/example/mouse17/output_full \
        --reference=hdfs:///crossbow-refs/mm9_chr17.jar

[mm9]: http://hgdownload.cse.ucsc.edu/downloads.html#mouse

### Single computer

<div id="cb-example-mouse17-local" />

First we build a reference jar for a human assembly and annotations
using scripts included with Crossbow.  The script searches for a
`bowtie-build` executable with the same rules Crossbow uses to search
for `bowtie`.  See [Installing Crossbow] for details.  Because one of
the steps executed by the script builds an index of the human genome,
it should be run on a computer with plenty of memory (at least 4
gigabytes, preferably 6 or more).

Run the following commands:

    cd $CROSSBOW_HOME/reftools
    ./mm9_chr17_jar

The `mm9_chr17_jar` script will automatically:

1. Download the FASTA sequence for mouse (build [mm9]) chromome 17 from
   [UCSC].
2. Build an index from that FASTA sequence.
3. Download the known SNPs and SNP frequencies for mouse chromosome 17
   from [dbSNP].
4. Arrange this information in the directory structure expected by
   Crossbow.
5. Package the information in a [jar file] named `mm9_chr17.jar`.

Move the directory containing the new reference jar into the
`$CROSSBOW_REFS` directory:

    mv $CROSSBOW_HOME/reftools/mm9_chr17 $CROSSBOW_REFS/

Now change to the `$CROSSBOW_HOME/example/mouse17` directory and run
Crossbow (substitute the number of CPUs you'd like to use for
`<CPUS>`):

    cd $CROSSBOW_HOME/example/mouse17
    $CROSSBOW_HOME/cb_local \
        --input=$CROSSBOW_HOME/example/mouse17/full.manifest \
        --preprocess \
        --reference=$CROSSBOW_REFS/mm9_chr17 \
        --output=output_full \
        --cpus=<CPUS>

[UCSC]: http://hgdownload.cse.ucsc.edu/downloads.html

# Manifest files

A manifest file describes a set of [FASTQ] or [`.sra`] formatted input
files that might be located:

[gzip]: http://en.wikipedia.org/wiki/Gzip
[bzip2]: http://en.wikipedia.org/wiki/Bzip2

1. On the local computer
2. In [HDFS]
3. In [S3]
4. On an FTP or web server

[FASTQ]: http://en.wikipedia.org/wiki/FASTQ_format

A manifest file can contain any combination of URLs and local paths from these
various types of sources.

[FASTQ] files can be gzip or bzip2-compressed (i.e. with `.gz` or `.bz2` file
extensions).  If [`.sra`] files are specified in the manifest and Crossbow is
being run in single-computer or [Hadoop] modes, then the `fastq-dump` tool must
be installed and Myrna must be able to locate it.  See the [`--fastq-dump`]
option and the [SRA Toolkit section of the manual].

[SRA Toolkit section of the manual]: #the-fastq-dump

Each line in the manifest file represents either one file, for unpaired input
reads, or a pair of files, for paired input reads.  For a set of unpaired input
reads, the line is formatted:

    URL(tab)Optional-MD5

Specifying an MD5 for the input file is optional.  If it is specified, Crossbow
will attempt to check the integrity of the file after downloading by comparing
the observed MD5 to the user-provided MD5. To disable this checking, specify `0`
in this field.

For a set of paired input reads, the line is formatted:

    URL-1(tab)Optional-MD5-1(tab)URL-2(tab)Optional-MD5-2

Where `URL-1` and `URL-2` point to input files with all the #1 mates in `URL-1`
and all the #2 mates in `URL-2`.  The entries in the files must be arranged so
that pairs "line up" in parallel.  This is commonly the way public paired-end
FASTQ datasets, such as those produced by the [1000 Genomes Project], are
formatted.  Typically these file pairs end in suffixes `_1.fastq.gz` and
`_2.fastq.gz`.

[1000 Genomes Project]: http://www.1000genomes.org/page.php

Manifest files may have comment lines, which must start with the hash (`#`)
symbol, and blank lines.  Such lines are ignored by Crossbow.

For examples of manifest files, see the files ending in `.manifest` in
the `$CROSSBOW_HOME/example/e_coli` and
`$CROSSBOW_HOME/example/mouse17` directories.

# Reference jars

All information about a reference sequence needed by Crossbow is encapsulated in
a "reference jar" file.  A reference jar includes a set of FASTA files encoding
the reference sequences, a [Bowtie] index of the reference sequence, and a set
of files encoding information about known SNPs for the species.

A Crossbow reference jar is organized as:

1. A `sequences` subdirectory containing one FASTA file per reference sequence.
2. An `index` subdirectory containing the [Bowtie] index files for the reference
   sequences.
3. A `snps` subdirectory containing all of the SNP description files.
 
The FASTA files in the `sequences` subdirectory must each be named `chrX.fa`,
where `X` is the 0-based numeric id of the chromosome or sequence in the file. 
For example, for a human reference, chromosome 1's FASTA file could be named
`chr0.fa`, chromosome 2 named `chr1.fa`, etc, all the way up to chromosomes 22,
X and Y, named `chr21.fa`, `chr22.fa` and `chr23.fa`.  Also, the names of the
sequences within the FASTA files must match the number in the file name.  I.e.,
the first line of the FASTA file `chr0.fa` must be `>0`. 

The index files in the `index` subdirectory must have the basename `index`. 
I.e., the index subdirectory must contain these files:
 
    index.1.ebwt
    index.2.ebwt
    index.3.ebwt
    index.4.ebwt
    index.rev.1.ebwt
    index.rev.2.ebwt

The index must be built using the [`bowtie-build`] tool distributed with
[Bowtie].  When `bowtie-build` is executed, the FASTA files specified on the
command line must be listed in ascending order of numeric id.  For instance, for
a set of FASTA files encoding human chromosomes 1,2,...,22,X,Y as
`chr0.fa`,`chr1.fa`,...,`chr21.fa`, `chr22.fa`,`chr23.fa`, the command for
`bowtie-build` must list the FASTA files in that order:
 
    bowtie-build chr0.fa,chr1.fa,...,chr23.fa index
  
The SNP description files in the `snps` subdirectory must also have names that
match the corresponding FASTA files in the `sequences` subdirectory, but with
extension `.snps`.  E.g. if the sequence file for human Chromosome 1 is named
`chr0.fa`, then the SNP description file for Chromosome 1 must be named
`chr0.snps`.  SNP description files may be omitted for some or all chromosomes.

The format of the SNP description files must match the format expected by
[SOAPsnp]'s `-s` option.  The format consists of 1 SNP per line, with the
following tab-separated fields per SNP:
 
1.  Chromosome ID
2.  1-based offset into chromosome
3.  Whether SNP has allele frequency information (1 = yes, 0 = no)
4.  Whether SNP is validated by experiment (1 = yes, 0 = no)
5.  Whether SNP is actually an indel (1 = yes, 0 = no)
6.  Frequency of A allele, as a decimal number
7.  Frequency of C allele, as a decimal number
8.  Frequency of T allele, as a decimal number
9.  Frequency of G allele, as a decimal number
10. SNP id (e.g. a [dbSNP] id such as `rs9976767`)
 
Once these three subdirectories have been created and populated, they can be
combined into a single [jar file] with a command like this:

[jar file]: http://en.wikipedia.org/wiki/JAR_(file_format)

    jar cf ref-XXX.jar sequences snps index
 
To use `ref-XXX.jar` with Crossbow, you must copy it to a location where it can
be downloaded over the internet via HTTP, FTP, or S3. Once it is placed in such
a location, make a note if its URL.

[`bowtie-build`]: http://bowtie-bio.sourceforge.net/manual.shtml#indx
[dbSNP]: http://www.ncbi.nlm.nih.gov/projects/SNP/

## Building a reference jar using automatic scripts
  
The `reftools` subdirectory of the Crossbow package contains scripts that assist
in building reference jars, including scripts that handle the entire process of
building reference jars for [hg18] (UCSC human genome build 18) and [mm9] (UCSC
mouse genome build 9).  The `db2ssnp` script combines SNP and allele frequency
information from [dbSNP] to create a `chrX.snps` file for the `snps`
subdirectory of the reference jar.  The `db2ssnp_*` scripts drive the `db2ssnp`
script for each chromosome in the [hg18] and [mm9] genomes.  The `*_jar` scripts
drive the entire reference-jar building process, including downloading reference
FASTA files, building a Bowtie index, and using `db2ssnp` to generate the `.snp`
files for [hg18] and [mm9].

[hg18]: http://hgdownload.cse.ucsc.edu/downloads.html#human
[mm9]: http://hgdownload.cse.ucsc.edu/downloads.html#mouse
[dbSNP]: http://www.ncbi.nlm.nih.gov/projects/SNP/

# Monitoring, debugging and logging

## Single computer

Single-computer runs of Crossbow are relatively easy to monitor and debug.
Progress messages are printed to the console as the job runs.  When there is a
fatal error, Crossbow usually indicates exactly which log file on the local
filesystem contains the relevant error message. Additional debugging is possible
when intermediate and temporary files are kept rather than discarded; see
[`--keep-intermediates`] and [`--keep-all`].  All output and logs are stored on
the local filesystem; see [`--intermediate`](#cb-local-intermediate) and
[`--output`](#cb-local-output) options.

## Hadoop

The simplest way to monitor Crossbow [Hadoop] jobs is via the Hadoop JobTracker.
 The JobTracker is a web server that provides a point-and-click interface for
monitoring jobs and reading output and other log files generated by those jobs,
including after they've finished.

When a job fails, you can often find the relevant error message by "drilling
down" from the "step" level through the "job" level and "task" levels, and
finally to the "attempt" level.  To diagnose why an attempt failed, click
through to the "stderr" ("standard error") log and scan for the relevant error
message.

See your version of Hadoop's documentation for details on how to use the web
interface.  Amazon has a brief document describing [How to Use the Hadoop User
Interface], though some of the instructions are specific to clusters rented from
Amazon.  [Hadoop, the Definitive Guide] is also an excellent reference.

[How to Use the Hadoop User Interface]: http://docs.amazonwebservices.com/ElasticMapReduce/latest/DeveloperGuide/index.html?UsingtheHadoopUserInterface.html
[Hadoop, the Definitive Guide]: http://oreilly.com/catalog/9780596521981

## EMR

The recommended way to monitor EMR [Hadoop] jobs is via the [AWS Console].  The
[AWS Console] allows you to see:

1. The status for job (e.g. "COMPLETED", "RUNNING" or "FAILED")
2. The status for each step of each job 
3. How long a job has been running for and how many "compute units" have been
   utilized so far.
4. The exact Hadoop commands used to initiate each job step.
5. The button for [Debugging Job Flows]

<div>
<img src="images/AWS_console.png" alt="Screen shot of AWS console with interface elements labeled" />
<p><i>Screen shot of [AWS Console] interface with some relevant interface elements labeled</i></p>
</div>

The [AWS Console] also has a useful facility for [Debugging Job Flows], which is
accessible via the "Debug" button on the "Elastic MapReduce" tab of the Console
(labeled "5").  You must (a) have a [SimpleDB] account (b) not have specified
[`--no-emr-debug`] in order to use all of the [EMR Debug] interface's features:

<div>
<img src="images/AWS_console_debug.png" alt="Screen shot of AWS console debug interface" />
<p><i>Screen shot of [EMR Debug] interface</i></p>
</div>

The debug interface is similar to Hadoop's JobTracker interface. When a job
fails, you can often find the relevant error message by "drilling down" from the
"job" level, through the "task" level, and finally to the "attempt" level.  To
diagnose why an attempt failed, click through to the "stderr" ("standard error")
log and scan for the relevant error message.

For more information, see Amazon's document on [Debugging Job Flows].

[Debugging Job Flows]: http://docs.amazonwebservices.com/ElasticMapReduce/latest/DeveloperGuide/index.html?DebuggingJobFlows.html
[EMR Debug]: http://docs.amazonwebservices.com/ElasticMapReduce/latest/DeveloperGuide/index.html?DebuggingJobFlows.html

## AWS Management Console

A simple way to monitor your EMR activity is via the [AWS Console]. The [AWS
Console] summarizes current information regarding all your running [EC2] nodes
and [EMR] jobs.  Each job is listed in the "Amazon Elastic MapReduce" tab of the
console, whereas individual [EC2] nodes are listed in the "Amazon EC2" tab.

<div>
<img src="images/AWS_console_upper_left.png" alt="Screen shot of AWS console tabs" />
<p><i>Screen shot of [AWS console]; note tabs for "Amazon Elastic MapReduce" and "Amazon EC2"</i></p>
</div>

# Crossbow Output

Once a Crossbow job completes successfully, the output is deposited in a
`crossbow_results` subdirectory of the specified `--output` directory or URL. 
Within the `crossbow_results` subdirectory, results are organized as one gzipped
result file per chromosome.  E.g. if your run was against the [hg18] build of
the human genome, the output files from your experiment will named:

    <output_url>/crossbow_results/chr1.gz
    <output_url>/crossbow_results/chr2.gz
    <output_url>/crossbow_results/chr3.gz
    ...
    <output_url>/crossbow_results/chr21.gz
    <output_url>/crossbow_results/chr22.gz
    <output_url>/crossbow_results/chrX.gz
    <output_url>/crossbow_results/chrY.gz
    <output_url>/crossbow_results/chrM.gz

Each individual record is in the [SOAPsnp] output format.  SOAPsnp's format
consists of 1 SNP per line with several tab-separated fields per SNP.  The
fields are:
 
1.  Chromosome ID
2.  1-based offset into chromosome
3.  Reference genotype
4.  Subject genotype
5.  Quality score of subject genotype
6.  Best base
7.  Average quality score of best base
8.  Count of uniquely aligned reads corroborating the best base
9.  Count of all aligned reads corroborating the best base
10. Second best base
11. Average quality score of second best base
12. Count of uniquely aligned reads corroborating second best base
13. Count of all aligned reads corroborating second best base
14. Overall sequencing depth at the site
15. Sequencing depth of just the paired alignments at the site
16. Rank sum test P-value
17. Average copy number of nearby region
18. Whether the site is a known SNP from the file specified with `-s`

Note that field 15 was added in Crossbow and is not output by unmodified SOAPsnp.

For further details, see the [SOAPsnp] manual.

# Other reading

The [Crossbow paper] discusses the broad design philosophy of both [Crossbow]
and [Myrna] and why cloud computing can be considered a useful trend for
comparative genomics applications.  The [Bowtie paper] discusses the alignment
algorithm underlying [Bowtie].

[Bowtie paper]: http://genomebiology.com/2009/10/3/R25
[Crossbow]: http://bowtie-bio.sf.net/crossbow
[Crossbow paper]: http://genomebiology.com/2009/10/11/R134

For additional information regarding Amazon EC2, S3, EMR, and related
services, see Amazon's [AWS Documentation].  Some helpful screencasts
are posted on the [AWS Console] home page.

[AWS Documentation]: http://aws.amazon.com/documentation/

For additional information regarding Hadoop, see the [Hadoop web site] and
[Cloudera's Getting Started with Hadoop] document.  [Cloudera's training virtual
machine] for [VMWare] is an excellent way to get acquainted with Hadoop without
having to install it on a production cluster.

[Cloudera's Getting Started with Hadoop]: http://www.cloudera.com/resource/getting_started_with_hadoop
[Cloudera's training virtual machine]: http://www.cloudera.com/developers/downloads/virtual-machine/
[VMWare]: http://www.vmware.com/
[Hadoop web site]: http://hadoop.apache.org/

# Acknowledgements

[Crossbow] software is by [Ben Langmead] and [Michael C. Schatz].

[Bowtie] software is by [Ben Langmead] and [Cole Trapnell].

[SOAPsnp] is by Ruiqiang Li, Yingrui Li, Xiaodong Fang, Huanming Yang, Jian
Wang, Karsten Kristiansen, and Jun Wang.

[Ben Langmead]: http://faculty.jhsph.edu/default.cfm?faculty_id=2209&grouped=false&searchText=&department_id=3&departmentName=Biostatistics
[Michael C. Schatz]: http://www.cbcb.umd.edu/~mschatz/
[Cole Trapnell]: http://www.cs.umd.edu/~cole/
