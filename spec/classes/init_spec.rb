require 'spec_helper'

describe 'autofs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('autofs') }
      it { is_expected.to contain_class('autofs::install') }
      it { is_expected.to contain_class('autofs::config') }
      it { is_expected.to contain_class('autofs::service') }
    end
  end
end
