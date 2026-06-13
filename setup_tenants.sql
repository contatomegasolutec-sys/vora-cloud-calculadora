-- 1. Criar Tabela de Tenants (Empresas/Parceiros)
CREATE TABLE IF NOT EXISTS public.tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    logo_text TEXT DEFAULT '',
    logo_image TEXT DEFAULT '',
    phrase TEXT DEFAULT '',
    rate_mode TEXT DEFAULT 'percentage', -- 'percentage' ou 'coefficient'
    cards_data JSONB DEFAULT '[]'::jsonb,
    whatsapp_number TEXT DEFAULT '5562994049949',
    whatsapp_message TEXT DEFAULT 'olá preciso de suporte para a calculadora',
    structure_type TEXT DEFAULT 'individual', -- 'individual' ou 'group'
    is_blocked BOOLEAN DEFAULT false,
    access_type TEXT DEFAULT 'lifetime', -- 'lifetime' ou 'monthly'
    expires_at TIMESTAMPTZ DEFAULT null,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Alterar a Tabela de Perfis para associar Gestores a um Tenant
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'profiles' 
          AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE public.profiles 
        ADD COLUMN tenant_id UUID REFERENCES public.tenants(id) ON DELETE SET NULL;
    END IF;
END $$;

-- Garantir coluna structure_type na tabela tenants
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'tenants' 
          AND column_name = 'structure_type'
    ) THEN
        ALTER TABLE public.tenants 
        ADD COLUMN structure_type TEXT DEFAULT 'individual';
    END IF;
END $$;

-- Garantir colunas de assinatura/bloqueio na tabela tenants
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'tenants' 
          AND column_name = 'is_blocked'
    ) THEN
        ALTER TABLE public.tenants ADD COLUMN is_blocked BOOLEAN DEFAULT false;
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'tenants' 
          AND column_name = 'access_type'
    ) THEN
        ALTER TABLE public.tenants ADD COLUMN access_type TEXT DEFAULT 'lifetime';
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'tenants' 
          AND column_name = 'expires_at'
    ) THEN
        ALTER TABLE public.tenants ADD COLUMN expires_at TIMESTAMPTZ DEFAULT null;
    END IF;
END $$;

-- 3. Criar Tabela de Visitantes de Tenants (Leads da Empresa)
CREATE TABLE IF NOT EXISTS public.tenant_visitors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Habilitar RLS (Row Level Security) nas novas tabelas e perfis
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenant_visitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 5. Criar Políticas para a tabela public.tenants (Acesso público / anônimo condizente com o restante do banco)
DROP POLICY IF EXISTS "Acesso público de leitura para tenants" ON public.tenants;
CREATE POLICY "Acesso público de leitura para tenants" ON public.tenants 
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Acesso total para gestor global ou gestor do tenant" ON public.tenants;
CREATE POLICY "Acesso público de inserção para tenants" ON public.tenants
    FOR INSERT WITH CHECK (true);
CREATE POLICY "Acesso público de atualização para tenants" ON public.tenants
    FOR UPDATE USING (true);

-- 6. Criar Políticas para a tabela public.tenant_visitors
DROP POLICY IF EXISTS "Acesso público para inserir visitantes" ON public.tenant_visitors;
CREATE POLICY "Acesso público para inserir visitantes" ON public.tenant_visitors
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Acesso para gestores verem seus visitantes" ON public.tenant_visitors;
CREATE POLICY "Acesso público de leitura para visitantes" ON public.tenant_visitors
    FOR SELECT USING (true);

-- Política de Deleção de Perfis (para remover lojistas no painel)
DROP POLICY IF EXISTS "Acesso público de deleção para profiles" ON public.profiles;
CREATE POLICY "Acesso público de deleção para profiles" ON public.profiles
    FOR DELETE USING (true);

-- 7. Inserir Tenant padrão da GYN STORE (Iniciando como estrutura de grupo)
INSERT INTO public.tenants (slug, name, logo_text, phrase, cards_data, structure_type)
VALUES (
    'gynstore',
    'GYN STORE',
    'G',
    'Calculadora GYN Store',
    '[
      {"name": "VISA", "color": "#0d47a1", "maxParc": 12, "pixRate": 0, "debitRate": 0, "rates": [2.50, 3.68, 4.53, 5.38, 6.23, 7.08, 8.23, 9.08, 9.93, 10.78, 11.63, 12.48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]},
      {"name": "MasterCard", "color": "#f57f17", "maxParc": 12, "pixRate": 0, "debitRate": 0, "rates": [2.50, 3.68, 4.53, 5.38, 6.23, 7.08, 8.23, 9.08, 9.93, 10.78, 11.63, 12.48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]},
      {"name": "ELO", "color": "#000000", "maxParc": 12, "pixRate": 0, "debitRate": 0, "rates": [2.50, 3.68, 4.53, 5.38, 6.23, 7.08, 8.23, 9.08, 9.93, 10.78, 11.63, 12.48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]},
      {"name": "Hiper", "color": "#c62828", "maxParc": 12, "pixRate": 0, "debitRate": 0, "rates": [2.50, 3.68, 4.53, 5.38, 6.23, 7.08, 8.23, 9.08, 9.93, 10.78, 11.63, 12.48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}
    ]'::jsonb,
    'group'
)
ON CONFLICT (slug) DO UPDATE SET structure_type = 'group';

-- 8. Inserir perfil de Gestor da GYN STORE (Usuario fabio e Senha FFabio123)
DO $$
DECLARE
    gynstore_id UUID;
BEGIN
    SELECT id INTO gynstore_id FROM public.tenants WHERE slug = 'gynstore';
    
    -- Remover registros anteriores com o nome 'FABIO' ou 'fabio' para evitar chaves duplicadas ou duplicidade de gestores
    DELETE FROM public.profiles WHERE name = 'FABIO' OR name = 'fabio';
    
    IF gynstore_id IS NOT NULL THEN
        INSERT INTO public.profiles (phone, name, is_manager, tenant_id)
        VALUES ('FFabio123', 'fabio', true, gynstore_id)
        ON CONFLICT (phone) DO UPDATE 
        SET name = 'fabio', is_manager = true, tenant_id = gynstore_id;
    END IF;
END $$;
