<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '../lib/supabase';

  let connectionStatus = 'Probando conexión...';
  let connectionClass = 'alert-info';
  let details = '';

  onMount(async () => {
    try {
      // Test 1: Check if Supabase client is initialized
      if (!supabase) {
        throw new Error('Supabase client not initialized');
      }

      // Test 2: Try to query tenants table
      const { data, error } = await supabase
        .from('tenants')
        .select('id, nombre')
        .limit(1);

      if (error) {
        connectionStatus = '❌ Error de conexión';
        connectionClass = 'alert-error';
        details = `Error: ${error.message}`;
      } else {
        connectionStatus = '✅ Conexión exitosa a Supabase';
        connectionClass = 'alert-success';
        details = data && data.length > 0 
          ? `Tenant encontrado: ${data[0].nombre}` 
          : 'Base de datos vacía (ejecuta el schema SQL)';
      }
    } catch (err: any) {
      connectionStatus = '❌ Error crítico';
      connectionClass = 'alert-error';
      details = err.message;
    }
  });
</script>

<div class="container mx-auto p-8">
  <h1 class="text-3xl font-bold mb-6">Test de Conexión Supabase</h1>

  <div class={`alert ${connectionClass} mb-4`}>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      class="stroke-current shrink-0 w-6 h-6"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        stroke-width="2"
        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      ></path>
    </svg>
    <div>
      <h3 class="font-bold">{connectionStatus}</h3>
      {#if details}
        <div class="text-sm">{details}</div>
      {/if}
    </div>
  </div>

  <div class="card bg-base-200 shadow-xl">
    <div class="card-body">
      <h2 class="card-title">Información de Configuración</h2>
      <div class="space-y-2">
        <p>
          <strong>Supabase URL:</strong>
          {import.meta.env.VITE_SUPABASE_URL || '❌ No configurado'}
        </p>
        <p>
          <strong>Anon Key:</strong>
          {import.meta.env.VITE_SUPABASE_ANON_KEY
            ? '✅ Configurado'
            : '❌ No configurado'}
        </p>
      </div>
    </div>
  </div>

  <div class="mt-6">
    <a href="/" class="btn btn-primary">Volver al inicio</a>
  </div>
</div>
