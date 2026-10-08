<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <title>Réinitialisation de mot de passe - Voltigex</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        .text-content {
            font-size: 12px;
            color: #555555;
            line-height: 1.7;
        }
        
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
            position: relative;
            overflow: hidden;
        }
        
        .header {
            background-color: #ffffff;
            padding: 30px 20px 20px;
            text-align: center;
        }
        
        .banner {
            width: 100%;
            height: 10px;
            background: linear-gradient(135deg, #082054 0%, #082054 50%, #082054 100%);
            position: relative;
            overflow: hidden;
            border-top-right-radius: 50px;
            border-top-left-radius: 50px;
        }
        
        .content {
            background-color: #ffffff;
            padding: 30px 30px;
            color: #333333;
        }
        
        .content h1 {
            font-size: 32px;
            font-weight: 700;
            color: #082054;
            margin-bottom: 20px;
            line-height: 1.2;
        }
        
        .greeting {
            font-size: 16px;
            color: #333333;
            margin-bottom: 20px;
        }
        
        .intro-text {
            font-size: 15px;
            color: #555555;
            line-height: 1.7;
            margin-bottom: 15px;
        }
        
        .info-box {
            background-color: #f0f9ff;
            border-left: 4px solid #082054;
            padding: 20px;
            margin: 25px 0;
            border-radius: 5px;
        }
        
        .info-box p {
            margin: 0;
            color: #082054;
            font-weight: 500;
        }
        
        .footer {
            background: linear-gradient(135deg, #082054 0%, #082054 100%);
            color: #ffffff;
            padding: 40px 30px;
            padding-bottom: 10px;
        }
        
        .footer-content {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 30px;
        }
        
        .footer-left {
            flex: 1;
            min-width: 200px;
        }
        
        .footer-logo {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 15px;
        }
        
        .footer-website {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.9);
        }
        
        .footer-right {
            flex: 1;
            min-width: 200px;
        }
        
        .social-icons {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .social-icon {
            width: 30px;
            height: 30px;
            background-color: #ffffff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #082054;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        
        .social-icon:hover {
            background-color: #005669;
            color: #ffffff;
            transform: scale(1.1);
        }
        
        .footer-links {
            gap: 15px;
            flex-wrap: wrap;
            font-size: 10px;
        }
        
        .footer-links a {
            color: rgba(255, 255, 255, 0.9);
            text-decoration: none;
            transition: color 0.3s ease;
        }
        
        .footer-links a:hover {
            color: #ffffff;
        }
        
        @media only screen and (max-width: 600px) {
            .content {
                padding: 30px 20px;
            }
            
            .content h1 {
                font-size: 26px;
            }
            
            .footer-content {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="email-container" style="border-radius: 10px; border: 0.5px solid #082054;">
        <div class="banner"></div>
        <div class="header">
            <img src="{{ asset('bank/images/favicon.png') }}" style="border-radius: 50%;" height="80" alt="Logo">
        </div>
        
        <div class="content">
            <h1 style="text-align: center;">Réinitialisation de mot de passe</h1>
            
            <p class="greeting" style="text-align: center;">Bonjour, {{ $mailData['nom'] ?? '' }} {{ $mailData['prenoms'] ?? '' }} !</p>
            
            <p class="intro-text">Vous avez demandé une réinitialisation de votre mot de passe. Veuillez cliquer sur le bouton ci-dessous pour définir un nouveau mot de passe :</p>
            
            <div class="info-box">
                <p><i class="fas fa-info-circle"></i> Ce lien expire dans 60 minutes. Si vous n'avez pas fait cette demande, vous pouvez ignorer cet email.</p>
            </div>
            
            <div style="text-align: center; margin-top: 30px;">
                <a href="{{ $resetUrl ?? '#' }}" style="background-color: #082054; color: #ffffff; padding: 12px 30px; border-radius: 5px; text-decoration: none; display: inline-block; font-weight: 600;">Réinitialiser mon mot de passe</a>
            </div>
            
            <p class="intro-text" style="margin-top: 25px;">Si vous n'avez pas fait cette demande, vous pouvez ignorer cet email. Votre mot de passe restera inchangé.</p>
            
            <p class="intro-text" style="margin-top: 25px;">Cordialement,<br>
            <strong>L'équipe Voltigex</strong></p>
        </div>
        
        <div class="footer">
            <div class="footer-content">
                <div class="footer-left">
                    <div class="footer-logo">
                        <img src="{{ asset('bank/images/favicon.png') }}" height="50" alt="Logo">
                    </div>
                    <p style="font-size: 10px; color: #ffffff;">Voltigex est votre partenaire de confiance pour tous vos besoins bancaires internationaux.</p>
                    <div class="footer-website">
                        <a href="https://Voltigex.com" target="_blank" style="text-decoration: underline;color:white;font-size: 12px;">Voltigex.com</a>
                    </div>
                </div>
                
                <div class="footer-right">                                     
                    <div class="footer-links">
                        <h4 style="font-size: 12px; color: #ffffff;margin-bottom: 8px;">Contactez nous</h4>
                        <ul>
                            <li style="font-size: 10px;"><i class="fas fa-phone"></i> +33 1 23 45 67 89</li>
                            <li style="font-size: 10px;"><i class="fas fa-envelope"></i> contact@Voltigex.com</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <div style="margin-left: 5px;margin-right: 5px">
            <hr style="background-color: white;border: white;padding: 0.5px;">
        </div>
        <div style="background-color: #082054;text-align: center;padding-bottom: 10px;padding-top: 10px;">
            <p style="font-size: 10px; color: #ffffff;">Copyright © {{ date('Y') }} Voltigex. Tous droits réservés.</p>
            <p style="font-size: 10px; color: #ffffff;">Cet email a été envoyé automatiquement. Merci de ne pas y répondre.</p>
        </div>
    </div>
</body>
</html>
