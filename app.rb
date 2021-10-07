#! /usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'sinatra'
  gem 'puma'
  gem 'faker'
end

# exit without Zoho chat widget code
widget_code = ENV.fetch('WIDGETCODE', '').strip
if widget_code == ''
  puts <<~HELP
    Turbo Zoho v1.0
    ur5us

    USAGE:
      WIDGETCODE=… ./app.rb
      WIDGETCODE=… ruby app.rb
  HELP
  exit 1
end

require 'sinatra/base'

quotes = Hash.new { |h, k| h[k] = Faker::Books::Dune.quote }

ZOHO_JAVASCRIPT = <<~JS
  !window.cached_elements && (window.cached_elements = undefined);
  document.addEventListener("turbo:before-cache", function() {
    if(!cached_elements) {
        cached_elements = document.querySelectorAll('[data-turbo-permanent]');
        //document.getElementById('cache_script').setAttribute('data-turbo-eval', false)
    }
  })

  document.addEventListener("turbo:load", function() {
    let len = cached_elements ? cached_elements.length : 0;

    for(let i = 0; i < len; i++) {
      document.body.appendChild(cached_elements[i]);
    }

    cached_elements && window.$ZSIQChat && window.$ZSIQChat.init()
  })

  var $zoho = $zoho || {};
  $zoho.salesiq = $zoho.salesiq || {
    widgetcode: "#{widget_code}",
    values: {},
    ready: function(){
      console.log("ready");
      $zoho.salesiq.tracking.forcesecure(true);
    }
  };
  var d = document;
  var s = d.createElement("script");
  s.type = "text/javascript";
  s.id = "zsiqscript";
  s.defer = true;
  s.src = "https://salesiq.zoho.com/widget";
  var t = d.getElementsByTagName("script")[0];
  t.parentNode.insertBefore(s,t);

  $zoho.salesiq.onload = function() {
    console.log("onload");
    var elemobj = document.querySelectorAll('[data-id="zsalesiq"]');
    var length = elemobj.length;
    for(var i = 0; i < length; i++){
        elemobj[i].setAttribute('data-turbo-permanent','');
    }
    document.querySelector('.siqembed').removeAttribute('data-turbo-permanent');
  }
JS

app = Sinatra.new do
  configure do
    set :port, 3000
  end

  template :layout do
    # technically the following is ERB but using `HTML` enables syntax highlighting
    <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <link
            href="data:image/x-icon;base64,AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAgAAAAAAAAAAAAAAAEAAAAAAAAAAZiuYA////AJ4Z5gD1hSIA5hm2ABkx5gAi2fUAWff/ABl55gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAZmZmZmZmZmZmYRERERFmZhERMzETMRERMzMzMzMzMzMzMzMRETMzMzERMzMzMzMzMzMzMzMzERMzMzMzMzMzM1VVd3d3d1VVAFV3d3d3VQAAAAd3d3AAACIAAHd3iIgiIiIgAAACIiJEIiIiIiIiRERERCIiREREREREREREREQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
            rel="icon"
            type="image/x-icon"
          />
          <style>
            body {
              margin: auto;
              max-width: 60em;
              text-align: center;
            }
            nav {
              display: flex;
              justify-content: space-evenly;
            }
          </style>
          <script>
            <%= ZOHO_JAVASCRIPT %>
          </script>
          <script type="module">
            import hotwiredTurbo from 'https://cdn.skypack.dev/@hotwired/turbo';
          </script>
        </head>
        <body>
          <%= yield %>
          <div id='zsiqwidget' data-turbo-permanent>
            <!--
              Rendering this element manually to avoid `d.write("<div id='zsiqwidget'></div>`
              as per https://www.zoho.com/salesiq/help/getting-started-share-code-with-webmaster-websites-page-v1.html
              Live Chat Code snippet as using this JavaScript API violates best practices.
            -->
            <!-- Zoho chat widget should inject DOM elements into this container element. -->
            </div>
        </body>
      </html>
    HTML
  end

  template :page do
    <<~ERB
      <h1>Random Dune quote</h1>
      <blockquote><%= @quote %></blockquote>
      <nav>
        <a href="<%= @previous %>">← Previous</a>
        <%= @id %>. Page
        <a href="<%= @next %>">Next →</a>
      </nav>
    ERB
  end

  get '/pages/:id' do |id|
    sleep rand(0.3..1.0) # slow down the site a little to actually notice that it refreshes
    @id = id.to_i
    @previous = url("/pages/#{@id - 1}")
    @next = url("/pages/#{@id + 1}")
    @quote = quotes[@id]
    erb :page
  end

  get '/' do
    redirect to('pages/1')
  end
end
app.run!
