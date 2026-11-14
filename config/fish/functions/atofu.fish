function atofu --description 'OpenTofu with ardotconsulting lab credentials'
    AWS_PROFILE=ardot op run --account cheley.1password.com --env-file=$HOME/Documents/ardotconsulting/infra/.env.op -- tofu $argv
end
