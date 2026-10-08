<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nouveau message de contact</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
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
            border-radius: 10px;
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #082054 0%, #082054 100%);
            color: #ffffff;
            padding: 30px 20px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 24px;
            margin-bottom: 10px;
        }
        
        .content {
            padding: 30px;
            color: #333333;
        }
        
        .info-section {
            background-color: #f9f9f9;
            border-left: 4px solid #082054;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .info-row {
            margin-bottom: 15px;
        }
        
        .info-row:last-child {
            margin-bottom: 0;
        }
        
        .info-label {
            font-weight: 600;
            color: #082054;
            margin-bottom: 5px;
            display: block;
        }
        
        .info-value {
            color: #555555;
            font-size: 15px;
        }
        
        .message-section {
            background-color: #ffffff;
            border: 1px solid #e0e0e0;
            padding: 20px;
            border-radius: 4px;
            margin-top: 20px;
        }
        
        .message-label {
            font-weight: 600;
            color: #082054;
            margin-bottom: 10px;
            display: block;
        }
        
        .message-content {
            color: #333333;
            line-height: 1.8;
            white-space: pre-wrap;
        }
        
        .footer {
            background-color: #082054;
            color: #ffffff;
            padding: 20px;
            text-align: center;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="email-container">
        <div class="header">
            <h1>Nouveau message de contact</h1>
            <p>Vous avez reçu un nouveau message depuis le formulaire de contact</p>
        </div>
        
        <div class="content">
            <div class="info-section">
                <div class="info-row">
                    <span class="info-label">Nom complet :</span>
                    <span class="info-value">{{ $mailData['firstName'] }} {{ $mailData['lastName'] }}</span>
                </div>
                
                <div class="info-row">
                    <span class="info-label">Email :</span>
                    <span class="info-value">{{ $mailData['email'] }}</span>
                </div>
                
                <div class="info-row">
                    <span class="info-label">Téléphone :</span>
                    <span class="info-value">{{ $mailData['phone'] }}</span>
                </div>
                
                <div class="info-row">
                    <span class="info-label">Sujet :</span>
                    <span class="info-value">{{ $mailData['subject_label'] ?? $mailData['subject'] }}</span>
                </div>
                
                <div class="info-row">
                    <span class="info-label">Date :</span>
                    <span class="info-value">{{ $mailData['date'] ?? now()->format('d/m/Y à H:i') }}</span>
                </div>
            </div>
            
            <div class="message-section">
                <span class="message-label">Message :</span>
                <div class="message-content">{{ $mailData['message'] }}</div>
            </div>
        </div>
        
        <div class="footer">
            <p>Cet email a été envoyé automatiquement depuis le formulaire de contact du site Voltigex.</p>
            <p style="margin-top: 10px;">© {{ date('Y') }} Voltigex. Tous droits réservés.</p>
        </div>
    </div>
</body>
</html>

