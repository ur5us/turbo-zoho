# Broken Turbo + Zoho Chat integration

This single-file Sinatra app attempts to integrate both
[Hotwire/Turbo](https://turbo.hotwired.dev) and
[Zoho Chat](https://www.zoho.com/salesiq/). To run the app, you’ll need have
Ruby installed. The following version of Ruby, RubyGems and Bundler were used
to create this demo:

```bash
$ ruby -v
ruby 3.0.2p107 (2021-07-07 revision 0db68f0233) [x86_64-linux]
$ gem -v
3.2.28
$ bundle -v
Bundler version 2.2.28
```

Then, simply run `WIDGETCODE=… ./app.rb` where you replace the `…` with your
valid widgetcode. You should see something along the lines of

```bash
WIDGETCODE=… ./app.rb
== Sinatra (v2.1.0) has taken the stage on 3000 for development with backup from Puma
Puma starting in single mode...
* Puma version: 5.5.0 (ruby 3.0.2-p107) ("Zawgyi")
*  Min threads: 0
*  Max threads: 5
*  Environment: development
*          PID: 516802
* Listening on http://127.0.0.1:3000
* Listening on http://[::1]:3000
Use Ctrl-C to stop
```

…and then you can use your browser to navigate to http://127.0.0.1:3000.

The page load and you can start navigating. Open your browser dev tools and
observe the console. If you wait for the `onload` callback to finish and *then*
start navigating it’s almost working. Note how the Zoho chat floating button
is constantly reloaded/re-rendred which is very distracting. The same thing
happens when the chat is actually triggered, i.e. open. The chat is constantly
re-initialized which is very distracting and most likely looses chat history.

Now, use the browser’s back/forward buttons while the chat window is open and
it breaks. The chat widget is opened, you can the shadow/border but it’s empty
empty otherwise.

Now, reload the page, close the chat window if open and reload again, then do
*not* wait for the `onload` callback to be executed and click the floating
button as fast as possible. You’ll see

```
Uncaught TypeError: t is undefined
    calculateContentHeight https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    handleResize https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    <anonymous> https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    dispatch https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    a https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    add https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    on https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    each https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    each https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    on https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    n https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
    <anonymous> https://js.zohocdn.com/salesiq/js/siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1
siqchatwindow1_2ee078a9058b61e084850bd62680acd9_.js:1:577838
```

There are probably more ways to break it. Long story short, it’s not working
reliably and even when it works it’s super janky and annoying.

To provide a nice UX it would be best if the chat window state could be
preserved entirely during page navigation via Turbo. This means, neither the
floating button nor an open chat are reloaded, re-rendered or re-initialized in
a user noticeable—or worse user distracting—way. Instead, it should feels like
it’s persisting across page loads similar to (single page) apps.