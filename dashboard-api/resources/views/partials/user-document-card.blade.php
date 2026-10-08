@php
    $docUrl = document_public_url($path ?? null);
    $extension = $path ? strtolower(pathinfo($path, PATHINFO_EXTENSION)) : '';
@endphp
<div class="border rounded p-3 text-center h-100">
    @if($docUrl)
        @if($extension === 'pdf')
            <i class="fas fa-file-pdf text-danger fa-3x mb-2"></i>
            <p class="mb-2 small text-muted">PDF</p>
            <a href="{{ $docUrl }}" target="_blank" rel="noopener" class="btn btn-sm btn-primary me-1">
                <i class="fas fa-eye"></i> Ouvrir
            </a>
            <a href="{{ $docUrl }}" download class="btn btn-sm btn-outline-primary">
                <i class="fas fa-download"></i> Télécharger
            </a>
        @else
            <a href="{{ $docUrl }}" target="_blank" rel="noopener">
                <img src="{{ $docUrl }}" alt="{{ $label ?? 'Document' }}" class="img-fluid rounded mb-2" style="max-height: 200px;" onerror="this.style.display='none'">
            </a>
            <br>
            <a href="{{ $docUrl }}" target="_blank" rel="noopener" class="btn btn-sm btn-primary mt-2">
                <i class="fas fa-eye"></i> Voir en grand
            </a>
        @endif
    @else
        <i class="fas fa-times-circle fa-2x mb-2 text-muted"></i>
        <p class="text-muted mb-0">Non fourni</p>
    @endif
</div>
