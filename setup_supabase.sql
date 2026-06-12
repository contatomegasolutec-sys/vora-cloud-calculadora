-- 1. Tabela de Perfis de Usuários
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    is_manager BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Tabela de Configurações, Taxas e Bandeiras
CREATE TABLE IF NOT EXISTS public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    brand_name TEXT DEFAULT 'VORA',
    brand_logo_text TEXT DEFAULT 'V',
    brand_logo_image TEXT DEFAULT '',
    rate_mode TEXT DEFAULT 'percentage', -- 'percentage' ou 'coefficient'
    copy_settings JSONB DEFAULT '{}'::jsonb,
    cards_data JSONB DEFAULT '[]'::jsonb,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Tabela de Histórico de Conexão dos Usuários
CREATE TABLE IF NOT EXISTS public.connection_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    logged_in_at TIMESTAMPTZ DEFAULT now()
);

-- Desabilitar RLS ou criar políticas permissivas para a anon key (custom login por telefone + nome)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connection_history ENABLE ROW LEVEL SECURITY;

-- Políticas para profiles
CREATE POLICY "Acesso público de leitura para profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Acesso público de inserção para profiles" ON public.profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Acesso público de atualização para profiles" ON public.profiles FOR UPDATE USING (true);

-- Políticas para user_settings
CREATE POLICY "Acesso público de leitura para user_settings" ON public.user_settings FOR SELECT USING (true);
CREATE POLICY "Acesso público de inserção para user_settings" ON public.user_settings FOR INSERT WITH CHECK (true);
CREATE POLICY "Acesso público de atualização para user_settings" ON public.user_settings FOR UPDATE USING (true);

-- Políticas para connection_history
CREATE POLICY "Acesso público de leitura para connection_history" ON public.connection_history FOR SELECT USING (true);
CREATE POLICY "Acesso público de inserção para connection_history" ON public.connection_history FOR INSERT WITH CHECK (true);
CREATE POLICY "Acesso público de atualização para connection_history" ON public.connection_history FOR UPDATE USING (true);

-- Inserir perfil inicial do Gestor (substitua pelo seu telefone e nome no painel depois se desejar)
INSERT INTO public.profiles (phone, name, is_manager)
VALUES ('123456789', 'Administrador Vora', true)
ON CONFLICT (phone) DO UPDATE SET is_manager = true;
