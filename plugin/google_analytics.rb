#
# Google Analytics plugin for tDiary
#
# Copyright (C) 2005 TADA Tadashi <sho@spc.gr.jp>
# You can redistribute it and/or modify it under GPL2.
#
if /^(?:latest|day|month|nyear|search)$/ =~ @mode then
	add_footer_proc do
		google_analytics_insert_code
	end
end

def google_analytics_insert_code
	return '' unless @conf['google_analytics.profile']
	<<-HTML
		<!-- Global site tag (gtag.js) - Google Analytics -->
		<script async src="https://www.googletagmanager.com/gtag/js?id=UA-#{@conf['google_analytics.profile']}"></script>
		<script>
			window.dataLayer = window.dataLayer || [];
			function gtag(){dataLayer.push(arguments);}
			gtag('js', new Date());

			gtag('config', 'UA-#{@conf['google_analytics.profile']}');
		</script>
	HTML
end

# UA-53836-1
add_conf_proc( 'google_analytics', 'Google Analytics' ) do
	if @mode == 'saveconf' then
		@conf['google_analytics.profile'] = @cgi.params['google_analytics.profile'][0]
		@conf['google_analytics.amp.profile'] = @cgi.params['google_analytics.amp.profile'][0]
	end
	r = <<-HTML
		<h3>Google Analytics Profile</h3>
		<p>set your Profile ID (NNNNN-N)</p>
		<p>UA-<input name="google_analytics.profile" value="#{h @conf['google_analytics.profile']}"></p>
	HTML
	if defined? AMP
		r << <<-HTML
			<h3>Google Analytics Profile for AMP page</h3>
			<p>set your Profile ID (NNNNN-N) for AMP page</p>
			<p><input name="google_analytics.amp.profile" value="#{h @conf['google_analytics.amp.profile']}"></p>
		HTML
	end
	r
end

if defined? AMP
	add_amp_header_proc do
		%Q|<script async custom-element="amp-analytics"
			src="https://cdn.ampproject.org/v0/amp-analytics-0.1.js"></script>|
	end

	add_amp_body_enter_proc do
		profile_id = %w(google_analytics.amp.profile google_analytics.profile).map {|key|
			@conf[key]
		}.find {|profile|
			profile && !profile.empty?
		}
		<<-HTML
			<amp-analytics type="googleanalytics" id="analytics1">
			<script type="application/json">
			{
				"vars": { "account": "UA-#{h profile_id}" },
				"triggers": { "trackPageview": { "on": "visible", "request": "pageview" } }
			}
			</script>
			</amp-analytics>
		HTML
	end
end
