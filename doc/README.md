SPRINGBOK Core
==========

This is the official reference wallet for SPRINGBOK digital currency and comprises the backbone of the SPRINGBOK peer-to-peer network. You can [download SPRINGBOK Core](https://www.SPRINGBOK.org/downloads/) or [build it yourself](#building) using the guides below.

Running
---------------------
The following are some helpful notes on how to run SPRINGBOK Core on your native platform.

### Unix

Unpack the files into a directory and run:

- `bin/springbok-qt` (GUI) or
- `bin/springbokd` (headless)

### Windows

Unpack the files into a directory, and then run SPRINGBOK-qt.exe.

### macOS

Drag SPRINGBOK Core to your applications folder, and then run SPRINGBOK Core.

### Need Help?

* See the [SPRINGBOK documentation]()
for help and more information.
* Ask for help on [SPRINGBOK Discord]()
* Ask for help on the [SPRINGBOK Forum]()

  (coming soon)

Building
---------------------
The following are developer notes on how to build SPRINGBOK Core on your native platform. They are not complete guides, but include notes on the necessary libraries, compile flags, etc.

- [macOS Build Notes](build-osx.md)
- [Unix Build Notes](build-unix.md)
- [Windows Build Notes](build-windows.md)
- [OpenBSD Build Notes](build-openbsd.md)
- [NetBSD Build Notes](build-netbsd.md)
- [Gitian Building Guide](gitian-building.md)

Development
---------------------
The SPRINGBOK Core repo's [root README](/README.md) contains relevant information on the development process and automated testing.

- [Developer Notes](developer-notes.md)
- [Productivity Notes](productivity.md)
- [Release Notes](release-notes.md)
- [Release Process](release-process.md)
- Source Code Documentation ***TODO***
- [Translation Process](translation_process.md)
- [Translation Strings Policy](translation_strings_policy.md)
- [Travis CI](travis-ci.md)
- [JSON-RPC Interface](JSON-RPC-interface.md)
- [Unauthenticated REST Interface](REST-interface.md)
- [Shared Libraries](shared-libraries.md)
- [BIPS](bips.md)
- [Dnsseed Policy](dnsseed-policy.md)
- [Benchmarking](benchmarking.md)

### Resources
* See the [SPRINGBOK Developer Documentation](https://SPRINGBOKcore.readme.io/)
  for technical specifications and implementation details.
* Discuss on the [SPRINGBOK Forum](https://SPRINGBOK.org/forum), in the Development & Technical Discussion board.
* Discuss on [SPRINGBOK Discord](http://staySPRINGBOKy.com)
* Discuss on [SPRINGBOK Developers Discord](http://chat.SPRINGBOKdevs.org/)

### Miscellaneous
- [Assets Attribution](assets-attribution.md)
- [SPRINGBOK.conf Configuration File](SPRINGBOK-conf.md)
- [Files](files.md)
- [Fuzz-testing](fuzzing.md)
- [Reduce Memory](reduce-memory.md)
- [Reduce Traffic](reduce-traffic.md)
- [Tor Support](tor.md)
- [Init Scripts (systemd/upstart/openrc)](init.md)
- [ZMQ](zmq.md)
- [PSBT support](psbt.md)

License
---------------------
Distributed under the [MIT software license](/COPYING).
This product includes software developed by the OpenSSL Project for use in the [OpenSSL Toolkit](https://www.openssl.org/). This product includes
cryptographic software written by Eric Young ([eay@cryptsoft.com](mailto:eay@cryptsoft.com)), and UPnP software written by Thomas Bernard.
