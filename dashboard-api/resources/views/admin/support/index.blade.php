<!doctype html>
<html lang="fr" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
    <meta name="color-scheme" content="dark light">
    <title>Voltigex | Chat client</title>
    <link rel="icon" href="{{ asset('assets/img/favicon.png') }}" type="image/x-icon">
    <link rel="stylesheet" type="text/css" href="{{ asset('gourou/css/main.css') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('gourou/css/utilities.css') }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.7.2/font/bootstrap-icons.css">
    <style>
        .chat-layout {
            height: calc(100vh - 220px);
        }
        .chat-conversations-list {
            max-height: 100%;
            overflow-y: auto;
        }
        .chat-messages {
            height: 500px;
            max-height: 500px;
            overflow-y: auto;
            padding: 16px;
            background-color: #f8fafc; /* Fond légèrement grisé pour faire ressortir les bulles */
            display: flex;
            flex-direction: column;
        }
        .message-wrapper {
            max-width: 80%;
            margin-bottom: 12px;
        }
        .message-user {
            align-self: flex-start;
        }
        .message-admin {
            align-self: flex-end;
        }
        .chat-message-bubble {
            padding: 10px 14px;
            font-size: 0.95rem;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.12);
            line-height: 1.4;
        }
        .message-user .chat-message-bubble {
            background-color: #f1f5f9; /* Gris clair */
            color: #111827; /* Texte foncé */
            border-radius: 16px 16px 16px 4px; /* coin inférieur gauche moins arrondi */
            border: 1px solid #e2e8f0;
        }
        .message-admin .chat-message-bubble {
            background-color: #1e3a8a; /* Bleu Voltigex */
            color: #ffffff;
            border-radius: 16px 16px 4px 16px; /* coin inférieur droit moins arrondi */
        }
        .chat-message-meta {
            font-size: 0.75rem;
            color: #64748b;
            margin-top: 4px;
            opacity: 0.8;
        }
        .cursor-pointer {
            cursor: pointer;
        }
        #conversations-list .list-group-item.active {
            background-color: #1e3a8a;
            border-left: 3px solid #ffffff;
            color: #ffffff;
            padding:10px;
        }
        #conversations-list .list-group-item:hover {
            background-color: #1e3a8a;
            color: #ffffff;
        }
    </style>
</head>
<body>
<div class="d-flex flex-column flex-lg-row h-lg-full bg-surface-secondary">
    <nav class="navbar show navbar-vertical h-lg-screen navbar-expand-lg px-0 py-3 navbar-light bg-white border-bottom border-bottom-lg-0 border-end-lg scrollbar" id="sidebar">
        <div class="container-fluid">
            <button class="navbar-toggler ms-n2" type="button" data-bs-toggle="collapse" data-bs-target="#sidebarCollapse" aria-controls="sidebarCollapse" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <a href="/" class="navbar-brand d-inline-block py-lg-2 mb-lg-5 px-lg-6 me-0">
                <img style="width: 80px;height: 80px;" src="{{ asset('bank/images/favicon.png') }}" alt="Voltigex">
            </a>
            <div class="navbar-user d-lg-none">
                <div class="dropdown">
                    <a href="#" id="sidebarAvatar" role="button" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <div class="avatar-parent-child">
                            <button style="background-color: #cf0c05;color:white;border-radius:50px;">
                                <i class="bi bi-person"></i>
                            </button>
                        </div>
                    </a>
                    @include('layouts/admin/profile-dropdown')
                </div>
            </div>
            @include('layouts/admin/header')
        </div>
    </nav>

    <div class="flex-lg-1 h-screen overflow-y-lg-auto">
        <nav class="navbar navbar-light position-lg-sticky top-lg-0 d-none d-lg-block overlap-10 flex-none bg-white border-bottom px-0 py-3" id="topbar">
            <div class="container-fluid">
                <div class="hstack gap-2"></div>
                <div class="navbar-user d-none d-sm-block">
                    <div class="hstack gap-3 ms-4">
                        <div class="dropdown">
                            <a class="d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown" aria-haspopup="false" aria-expanded="false">
                                <div>
                                    <div class="avatar avatar-sm rounded-circle text-white">
                                        <img class="rounded-circle" alt="..." src="{{ asset('bank/images/favicon.png') }}">
                                    </div>
                                </div>
                                <div class="d-none d-sm-block ms-3">
                                    <span class="h6">{{ Auth()->user()->nom.' '.Auth()->user()->prenom }}</span>
                                </div>
                                <div class="d-none d-md-block ms-md-2"><i class="bi bi-chevron-down text-muted text-xs"></i></div>
                            </a>
                            @include('layouts/admin/profile-dropdown')
                        </div>
                    </div>
                </div>
            </div>
        </nav>

        <header>
            <div class="container-fluid">
                <div class="border-bottom pt-6 pb-5">
                    <div class="row align-items-center">
                        <div class="col-sm col-12">
                            <h1 class="h2 ls-tight">Support client</h1>
                            <p class="text-muted mb-0">Gérez les conversations avec vos clients en temps réel.</p>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <main class="py-6 bg-surface-secondary">
            <div class="container-fluid">
                <div class="card">
                    <div class="card-body chat-layout">
                        <div class="row h-100">
                            <!-- Liste des conversations -->
                            <div class="col-lg-4 border-end d-flex flex-column">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5 class="mb-0">Conversations</h5>
                                </div>
                                <div id="conversations-list" class="chat-conversations-list list-group list-group-flush">
                                    <div class="text-center text-muted py-4" id="conversations-empty">
                                        Aucune conversation pour le moment.
                                    </div>
                                </div>
                            </div>

                            <!-- Fenêtre de chat -->
                            <div class="col-lg-8 d-flex flex-column">
                                <div id="chat-header" class="border-bottom pb-3 mb-3 d-flex justify-content-between align-items-center">
                                    <div>
                                        <h5 id="chat-client-name" class="mb-1">Sélectionnez une conversation</h5>
                                        <div id="chat-client-meta" class="small text-muted"></div>
                                    </div>
                                    <div id="chat-account-badges" class="d-flex gap-2"></div>
                                </div>

                                <div id="chat-messages" class="chat-messages mb-3">
                                    <div class="text-center text-muted py-5" id="chat-placeholder">
                                        Sélectionnez un client pour démarrer la discussion.
                                    </div>
                                </div>

                                <form id="chat-form" class="mt-auto border-top pt-3 d-none">
                                    @csrf
                                    <div class="input-group">
                                        <input type="text" id="chat-message-input" class="form-control" placeholder="Écrire un message au client...">
                                        <button class="btn btn-primary" type="submit">
                                            <i class="bi bi-send"></i>
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://js.pusher.com/7.2/pusher.min.js"></script>
<script>
    const csrfToken = '{{ csrf_token() }}';
    const pusherKey = '{{ config('broadcasting.connections.pusher.key') }}';
    const pusherCluster = '{{ env('PUSHER_APP_CLUSTER', 'mt1') }}';

    let currentConversationId = null;
    let currentParticipant = null;

    function formatDateTime(iso) {
        if (!iso) return '';
        const d = new Date(iso);
        return d.toLocaleString();
    }

    function renderConversations(conversations) {
        const list = $('#conversations-list');
        list.empty();

        if (!conversations.length) {
            list.append('<div id="conversations-empty" class="text-center text-muted py-4">Aucune conversation pour le moment.</div>');
            return;
        }

        conversations.forEach(function (conv) {
            const participant = conv.participant;
            const last = conv.last_message;
            const unread = conv.unread_count || 0;

            const item = $('<button></button>')
                .addClass('list-group-item list-group-item-action d-flex justify-content-between align-items-start text-start cursor-pointer')
                .attr('type', 'button')
                .data('conversation-id', conv.id)
                .data('participant', participant || null)
                .on('click', function () {
                    $('#conversations-list .list-group-item').removeClass('active');
                    $(this).addClass('active');
                    openConversation(conv.id, participant);
                });

            const displayName = (participant && (participant.display_name || participant.nom || participant.prenom)) ? (participant.display_name || (participant.nom + ' ' + participant.prenom).trim() || participant.alias || participant.email || 'Client #' + participant.id) : ('Conversation #' + conv.id);
            const body = $('<div></div>').addClass('me-auto');
            body.append('<div class="fw-semibold">' + displayName.replace(/</g, '&lt;').replace(/>/g, '&gt;') + '</div>');
            body.append('<div class="small text-muted text-truncate" style="max-width: 220px;">' + (last ? last.content || '[Message]' : 'Aucun message') + '</div>');

            item.append(body);

            if (unread > 0) {
                const badge = $('<span></span>')
                    .addClass('badge bg-danger rounded-pill align-self-center')
                    .text(unread);
                item.append(badge);
            }

            list.append(item);
        });
    }

    function renderMessages(response) {
        console.log("Données reçues de l'API :", response);

        const container = $('#chat-messages');
        container.empty();

        const messages = Array.isArray(response?.data)
            ? response.data
            : Array.isArray(response)
                ? response
                : [];
        if (!messages.length) {
            container.append('<div class="text-center text-muted py-5">Aucun message pour le moment.</div>');
            return;
        }

        messages.slice().reverse().forEach(function (msg) {
            const isAdmin = msg.sender && msg.sender.role === 'admin';

            const wrapper = $('<div></div>')
                .addClass('message-wrapper')
                .addClass(isAdmin ? 'message-admin' : 'message-user');

            const bubble = $('<div></div>')
                .addClass('chat-message-bubble')
                .text(msg.content || '[Message]');

            const meta = $('<div></div>')
                .addClass('chat-message-meta')
                .text(formatDateTime(msg.created_at));

            wrapper.append(bubble);
            wrapper.append(meta);

            container.append(wrapper);
        });

        container.scrollTop(container.prop('scrollHeight'));
    }

    function updateClientHeader(participant, account) {
        if (!participant) {
            $('#chat-client-name').text('Sélectionnez une conversation');
            $('#chat-client-meta').text('');
            $('#chat-account-badges').empty();
            return;
        }

        const clientName = participant.display_name || (participant.nom && participant.prenom ? (participant.nom + ' ' + participant.prenom) : null) || participant.alias || participant.email || ('Client #' + participant.id);
        $('#chat-client-name').text(clientName);
        $('#chat-client-meta').text(participant.email || participant.alias || '');

        const badges = $('#chat-account-badges');
        badges.empty();

        if (account) {
            if (typeof account.solde !== 'undefined') {
                badges.append('<span class="badge bg-success">Solde : ' + account.solde + ' ' + (account.devise || '€') + '</span>');
            }
            if (typeof account.account_status !== 'undefined') {
                const statusLabel = account.account_status === 1 ? 'Compte actif' : 'Compte inactif';
                const statusClass = account.account_status === 1 ? 'bg-primary' : 'bg-secondary';
                badges.append('<span class="badge ' + statusClass + '">' + statusLabel + '</span>');
            }
        }
    }

    function openConversation(conversationId, participant) {
        currentConversationId = conversationId;
        currentParticipant = participant;

        $('#chat-form').removeClass('d-none');
        $('#chat-placeholder').hide();

        if (participant && participant.id) {
            $.getJSON('/api/user-info/' + participant.id, function (res) {
                if (res.success && res.data) {
                    updateClientHeader(participant, res.data);
                } else {
                    updateClientHeader(participant, null);
                }
            }).fail(function () {
                updateClientHeader(participant, null);
            });
        } else {
            updateClientHeader(participant, null);
        }

        $.getJSON('/api/chat/conversations/' + conversationId, function (res) {
            renderMessages(res);
        });
    }

    function appendIncomingMessage(data) {
        if (!currentConversationId || data.conversation_id !== currentConversationId) {
            // On laisse la mise à jour de la liste des conversations indiquer l'activité
            loadConversations();
            return;
        }

        const container = $('#chat-messages');
        $('#chat-placeholder').hide();

        const isAdmin = data.sender && data.sender.role === 'admin';

        const wrapper = $('<div></div>')
            .addClass('message-wrapper')
            .addClass(isAdmin ? 'message-admin' : 'message-user');

        const bubble = $('<div></div>')
            .addClass('chat-message-bubble')
            .text(data.content || '[Message]');

        const meta = $('<div></div>')
            .addClass('chat-message-meta')
            .text(formatDateTime(data.created_at));

        wrapper.append(bubble);
        wrapper.append(meta);

        container.append(wrapper);
        container.scrollTop(container.prop('scrollHeight'));
    }

    function initPusher() {
        if (!pusherKey) {
            console.warn('PUSHER_APP_KEY non configurée. Le temps réel sera inactif.');
            return;
        }

        const pusher = new Pusher(pusherKey, {
            cluster: pusherCluster,
            authEndpoint: '/broadcasting/auth',
            auth: {
                headers: {
                    'X-CSRF-TOKEN': csrfToken,
                    'X-Requested-With': 'XMLHttpRequest'
                }
            }
        });

        // On s'abonne dynamiquement aux conversations quand elles seront ouvertes
        window.subscribeToConversation = function (conversationId) {
            const channel = pusher.subscribe('private-chat.' + conversationId);
            channel.bind('App\\Events\\MessageSent', function (data) {
                appendIncomingMessage(data);
            });
        };
    }

    function loadConversations(onLoaded) {
        $.ajax({
            url: '/api/chat/conversations',
            type: 'GET',
            dataType: 'json',
            headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Accept': 'application/json'
            },
            success: function (res) {
                const list = Array.isArray(res) ? res : (res && res.data ? res.data : []);
                renderConversations(list);
                if (!currentConversationId && list.length > 0 && typeof onLoaded !== 'function') {
                    const first = $('#conversations-list .list-group-item').first();
                    if (first.length) {
                        first.trigger('click');
                    }
                }
                if (typeof onLoaded === 'function') {
                    onLoaded(list);
                }
            },
            error: function (xhr) {
                const msg = xhr.status === 401
                    ? '<span class="text-danger">Session expirée ou non autorisée. <a href="' + (window.location.origin + '/login') + '">Reconnectez-vous</a>.</span>'
                    : 'Impossible de charger les conversations. Réessayez ou rechargez la page.';
                $('#conversations-list').empty().append('<div id="conversations-empty" class="text-center text-muted py-4">' + msg + '</div>');
            }
        });
    }

    $(function () {
        const params = new URLSearchParams(window.location.search);
        const conversationId = params.get('conversation_id');
        const userId = params.get('user_id');

        function openConversationById(convId, participant) {
            openConversation(convId, participant);
            $('#conversations-list .list-group-item').removeClass('active');
            $('#conversations-list .list-group-item[data-conversation-id="' + convId + '"]').addClass('active');
            if (window.subscribeToConversation) {
                window.subscribeToConversation(convId);
            }
            history.replaceState({}, '', window.location.pathname);
        }

        if (conversationId) {
            loadConversations(function (list) {
                const conv = Array.isArray(list) ? list.find(function (c) { return c.id == conversationId; }) : null;
                if (conv && conv.participant) {
                    openConversationById(conv.id, conv.participant);
                }
            });
        } else if (userId) {
            $.ajax({
                url: '/api/chat/conversations/with-user/' + userId,
                type: 'GET',
                dataType: 'json',
                headers: { 'X-Requested-With': 'XMLHttpRequest', 'Accept': 'application/json' },
                success: function (res) {
                    loadConversations(function () {
                        openConversationById(res.conversation_id, res.participant);
                    });
                },
                error: function () {
                    loadConversations();
                }
            });
        } else {
            loadConversations();
        }

        initPusher();

        $('#chat-form').on('submit', function (e) {
            e.preventDefault();
            const message = $('#chat-message-input').val().trim();
            if (!currentConversationId || !message) return;

            $.ajax({
                url: '/api/chat/messages',
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': csrfToken,
                    'Accept': 'application/json'
                },
                contentType: 'application/json',
                data: JSON.stringify({
                    conversation_id: currentConversationId,
                    type: 'text',
                    content: message
                }),
                success: function (res) {
                    $('#chat-message-input').val('');
                    appendIncomingMessage({
                        conversation_id: res.conversation_id,
                        content: res.content,
                        type: res.type,
                        internal_type: res.internal_type,
                        sender: {
                            id: res.sender_id,
                            role: 'admin'
                        },
                        created_at: res.created_at
                    });
                    loadConversations();
                }
            });
        });

        // Abonnement Pusher quand une conversation est ouverte
        $(document).on('click', '#conversations-list .list-group-item', function () {
            const convId = $(this).data('conversation-id');
            if (window.subscribeToConversation) {
                window.subscribeToConversation(convId);
            }
        });
    });
</script>

</body>
</html>
