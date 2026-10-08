<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Datas dynamiques -->
    <title>{{ config('app.meta.title') }} - Notifiche</title>
    <meta name="description" content="{{ config('app.meta.description') }}">
    <meta name="keywords" content="{{ config('app.meta.keywords') }}">
    <link rel="shortcut icon" type="image/x-icon" href="{{ config('app.favicon') }}">
    <!-- css du header -->
    <link rel="stylesheet" href="admin/assets/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Script du header -->
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
    <meta name="csrf-token" content="{{ csrf_token() }}">
  </head>
  <body>
      <div class="min-h-screen bg-gray-50">
        @include('layouts/utilisateur/header')

        <div class="container mx-auto px-4 py-8" style="padding-bottom: 100px;">
            <div class="bg-white rounded-lg shadow-lg overflow-hidden">
                <div class="p-6 border-b border-gray-200">
                    <div class="flex justify-between items-center">
                        <h2 class="text-2xl font-bold text-gray-900">Elenco delle notifiche</h2>
                        <button id="markAllRead" class="btn-primary bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg cursor-pointer">
                            Contrassegnare tutto come letto
                        </button>
                    </div>
                </div>

                <div class="divide-y divide-gray-200">
                    @forelse($notifications as $notification)
                        <div class="p-6 hover:bg-gray-50 transition-colors duration-200 {{ !$notification->is_read ? 'bg-red-50' : '' }}" 
                             data-notification-id="{{ $notification->id }}">
                            <div class="flex items-start">
                                <div class="ml-4 flex-1">
                                    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 sm:gap-0 p-2 rounded-md">
                                        <div>
                                            <h3 class="text-base sm:text-lg font-semibold text-gray-900">{{ $notification->titre }}</h3>
                                            <p class="mt-1 text-sm text-gray-600">{{ $notification->message }}</p>         
                                        </div> 
                                        <div class="flex flex-col items-start sm:items-end text-sm text-gray-500">
                                            <span>{{ $notification->created_at->diffForHumans() }}</span>
                                            @if(!$notification->is_read)
                                                <button id="markAllRead" class="mt-2 text-red-600 hover:text-red-700 mark-as-read cursor-pointer" style="cursor: pointer;">
                                                    Segna come letto
                                                </button>
                                            @endif
                                        </div>
                                    </div>                                    
                                </div>
                            </div>
                        </div>
                    @empty
                        <div class="p-6 text-center text-gray-500">
                            Nessuna notifica
                        </div>
                    @endforelse
                </div>

                <div class="p-4 border-t border-gray-200">
                    {{ $notifications->links() }}
                </div>
            </div>
        </div>

        @include('layouts/utilisateur/footer')      
      </div>

      <script>
      document.addEventListener('DOMContentLoaded', function() {
          // Marquer une notification comme lue
          document.querySelectorAll('.mark-as-read').forEach(button => {
              button.addEventListener('click', function() {
                  const notificationDiv = this.closest('[data-notification-id]');
                  const notificationId = notificationDiv.dataset.notificationId;
                  
                  fetch(`/notifications/${notificationId}/read`, {
                      method: 'POST',
                      headers: {
                          'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                          'Accept': 'application/json'
                      }
                  })
                  .then(response => response.json())
                  .then(data => {
                      if (data.success) {
                          notificationDiv.classList.remove('bg-red-50');
                          this.remove();
                          updateNotificationCount(data.unread_count);
                      }
                  });
              });
          });

          // Marquer toutes les notifications comme lues
          document.getElementById('markAllRead').addEventListener('click', function() {
              fetch('/notifications/mark-all-read', {
                  method: 'POST',
                  headers: {
                      'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                      'Accept': 'application/json'
                  }
              })
              .then(response => response.json())
              .then(data => {
                  if (data.success) {
                      document.querySelectorAll('[data-notification-id]').forEach(div => {
                          div.classList.remove('bg-red-50');
                          const markAsReadButton = div.querySelector('.mark-as-read');
                          if (markAsReadButton) {
                              markAsReadButton.remove();
                          }
                      });
                      updateNotificationCount(0);
                  }
              });
          });

          function updateNotificationCount(count) {
              const badge = document.querySelector('#notificationDropdown .badge');
              if (badge) {
                  badge.textContent = count;
                  if (count === 0) {
                      badge.classList.add('hidden');
                  } else {
                      badge.classList.remove('hidden');
                  }
              }
          }
      });
      </script>
    <script src="admin/assets/js/main.js"></script>
  </body>
</html> 