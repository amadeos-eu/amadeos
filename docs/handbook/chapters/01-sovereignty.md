# 1. Digital Sovereignty Starts on Your Desktop

Your computer is the place where your letters, photos, accounts and ideas live. *Digital sovereignty* means that you decide what happens there: which programs run, where your data is kept, who can read it and when the system changes. This chapter explains what that means in practice and what amadeOS does about it.

## Who decides on your computer?

On many computers today, the answer is: not you alone. A typical desktop

- asks you to sign in with an online account before you can use your own machine,
- sends usage data ("telemetry") to its maker, often switched on by default,
- stores documents in a cloud by default, on servers in another country and under another law,
- changes its look and its rules with every large update, whether you want it or not,
- shows advertising or "suggestions" inside the system itself.

None of this is a law of nature. It is a choice made by the companies that build those systems, and it binds you to them: your files, your habits and your skills depend on one vendor. Moving away becomes expensive. This is what *lock-in* means.

## What amadeOS does differently

amadeOS is built so that the answer is: **you**.

**Your computer works without an account.** You log in with a user name and password that are stored on the computer itself. No online account is needed to start, use or update amadeOS.

**Your data stays on your disk.** Documents, pictures and music are kept in the usual folders of your home directory. The applications save in open formats on your disk: the Calendar keeps your appointments in a plain iCalendar file, the Text Editor writes plain text in the encoding it found, WritePad is meant to save OpenDocument files. Nothing is copied to a cloud unless you put it there yourself.

**No telemetry.** The amadeOS desktop and its applications do not report how you use them. The web browser, Firefox ESR, comes with a configuration that switches its telemetry, studies, Pocket and sponsored content off, makes Ecosia the default search engine and installs the ad blocker uBlock Origin.

**Passwords are kept in your keyring.** The Mailer stores the passwords of your mail accounts in the desktop's keyring, not in a plain settings file and not on a server.

**You decide about updates.** amadeOS gets its updates from Debian, a community project, over ordinary package mirrors. Updates are offered, not forced.

The Front Panel shows when updates are waiting, in red when security updates are among them, and installs them when you ask (chapter 52). Automatic security updates are a setting you can turn on; they are off until you do.

**You can read every line.** All of amadeOS is free software. Anyone can read its source code, check what it does, change it and pass it on. Chapter 4 explains the licence, the EUPL.

## Sovereignty is not isolation

amadeOS does not cut you off from the world. It has a web browser, a mail client that talks to every IMAP and SMTP server, Gmail included, and it reads and writes the formats other systems use. The difference is that *you* open each of these doors, one at a time, and you can see which ones are open.

!!! sovereignty "Your data"
    Throughout this book, boxes like this one say where an application keeps your data and what it sends over the network. If a box is missing somewhere, that is a mistake in the book: please [report it](https://github.com/datazuul/amadeos/issues).

## Why "on your desktop"?

Most talk about digital sovereignty is about servers, clouds and data centres. Those matter. But the place where a person meets the digital world every day is the desktop: the screen, the programs, the files. If the desktop is not under your control, a sovereign data centre behind it helps little.

That is why amadeOS starts there. It does not invent a new kernel or a new way of installing software. It takes proven, free foundations (Linux and Debian) and adds what is missing for sovereignty on the desktop: a complete desktop and its everyday applications, understandable, open and made to last. The next chapter explains why that needs a distribution of its own.
