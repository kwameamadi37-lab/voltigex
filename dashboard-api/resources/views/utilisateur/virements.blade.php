<!DOCTYPE html>
<html lang="fr">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <!-- Datas dynamiques -->
      <title>{{ config('app.meta.title') }} - Trasferimento</title>
      <meta name="description" content="{{ config('app.meta.description') }}">
      <meta name="keywords" content="{{ config('app.meta.keywords') }}">
      <link rel="shortcut icon" type="image/x-icon" href="{{ config('app.favicon') }}">
      <!-- css du header -->
      <link rel="stylesheet" href="admin/assets/css/style.css">
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
      <!-- Script du header -->
      <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
  </head>
  <body>
      <div class="min-h-screen bg-gray-50">
        @include('layouts/utilisateur/header')   
          <!-- Main Content -->
          <div class="container mx-auto px-4 py-6" style="margin-bottom:50px;">
              
              <!-- Transaction History -->
              <div class="my-4">
                  <div class="card border-none shadow-md">
                      <div class="card-header">
                          <h2 class="card-title" style="color:#d51709;">Elenco dei trasferimenti</h2>
                          <p class="card-description">Le vostre ultime transazioni</p>
                      </div>
                      <div class="card-content">                           
                        <div class="relative overflow-x-auto">
                            <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
                                <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
                                    <tr class="pl-2">
                                        <th scope="col" class="px-6 py-4">
                                            Destinatario
                                        </th>
                                        <th scope="col" class="px-6 py-3">
                                            Importo
                                        </th>
                                        <th scope="col" class="px-6 py-3">
                                            Percentuale
                                        </th>
                                        <th scope="col" class="px-6 py-3">
                                            Azione
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($virements as $virement)
                                    <tr class="bg-white gap-4 border-b dark:bg-gray-800 dark:border-gray-700 border-gray-200">
                                        <th scope="row" class="md:px-4 py-4 font-medium text-gray-900 whitespace-nowrap">
                                            {{ $virement->nombanque }}
                                        </th>
                                        <td class="md:px-4 md:py-4">
                                            {{ $virement->montant }} €
                                        </td>
                                        <td class="md:px-4 md:py-4">
                                            <span class="bg-blue-100 rounded-full px-4">{{ $virement->pourcentage }} %</span> 
                                        </td>
                                        <td class="md:px-4 md:py-4">
                                            @if($virement->pourcentage != 99)
                                            <a href="{{ route('virement.finalisation', $virement->id) }}" class="btn  btn-primary">
                                                <span>Finalizzare</span>
                                            </a>
                                            @else

                                            @endif
                                        </td>
                                    </tr>    
                                    @endforeach                                
                                </tbody>
                            </table>
                        </div>

                          <div class="space-y-4">
                            <div class="mt-4">
                                {{ $virements->links() }}
                            </div>
                          </div>
                      </div>
                  </div>
              </div>
          </div>          
          @include('layouts/utilisateur/footer')      
      </div> 
      <script src="admin/assets/js/main.js"></script>
  </body>
</html>
