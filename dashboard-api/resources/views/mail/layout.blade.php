<!DOCTYPE html>
<html lang="{{ site_setting('default_locale', 'fr') }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('mail-title', 'Voltigex')</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
            line-height: 1.6;
        }
        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            border-radius: 10px;
            border: 0.5px solid #082054;
            overflow: hidden;
        }
        .banner {
            height: 10px;
            background: linear-gradient(135deg, #082054 0%, #1e3a8a 50%, #005669 100%);
        }
        .header { padding: 28px 20px 12px; text-align: center; }
        .content { padding: 24px 30px 30px; color: #333333; }
        .content h1 {
            font-size: 28px;
            font-weight: 700;
            color: #082054;
            margin-bottom: 18px;
            line-height: 1.2;
            text-align: center;
        }
        .intro-text { font-size: 15px; color: #555555; line-height: 1.7; margin-bottom: 14px; }
        .greeting { font-size: 16px; color: #333333; margin-bottom: 16px; text-align: center; }
        .info-box {
            background-color: #f0f9ff;
            border-left: 4px solid #082054;
            padding: 16px 18px;
            margin: 20px 0;
            border-radius: 5px;
            font-size: 14px;
            color: #082054;
        }
        .btn-primary {
            background-color: #1e3a8a;
            color: #ffffff !important;
            padding: 12px 28px;
            border-radius: 8px;
            text-decoration: none;
            display: inline-block;
            font-weight: 600;
            font-size: 15px;
        }
        .footer {
            background: linear-gradient(135deg, #082054 0%, #1e3a8a 100%);
            color: #ffffff;
            padding: 28px 24px 16px;
        }
        .footer p, .footer li { font-size: 11px; color: rgba(255,255,255,0.92); }
        .footer a { color: #ffffff; }
        .footer-bottom {
            background-color: #082054;
            text-align: center;
            padding: 12px;
            font-size: 10px;
            color: rgba(255,255,255,0.85);
        }
        .hours { white-space: pre-line; margin-top: 8px; }
        @media only screen and (max-width: 600px) {
            .content { padding: 24px 18px; }
            .content h1 { font-size: 22px; }
        }
    </style>
    @stack('mail-styles')
</head>
<body>
    <div class="email-container">
        <div class="banner"></div>
        <div class="header">
            <img src="{{ asset('bank/images/favicon.png') }}" style="border-radius: 50%;" height="72" alt="Voltigex">
        </div>
        <div class="content">
            @yield('mail-body')
        </div>
        <div class="footer">
            <p><strong>{{ site_setting('mail_from_name', 'Voltigex') }}</strong></p>
            <p style="margin-top:8px;">{{ site_setting('contact_phone') }} · {{ site_setting('contact_email') }}</p>
            @if(site_setting('opening_hours'))
                <p class="hours"><strong>Horaires :</strong><br>{{ site_setting('opening_hours') }}</p>
            @endif
            <p style="margin-top:12px;">
                <a href="{{ site_setting('brand_website_url', url('/')) }}">{{ site_setting('brand_website_url', 'voltigex.com') }}</a>
            </p>
        </div>
        <div class="footer-bottom">
            <p>Copyright © {{ date('Y') }} Voltigex. Tous droits réservés.</p>
            <p>Cet email a été envoyé automatiquement. Merci de ne pas y répondre directement.</p>
        </div>
    </div>
</body>
</html>
