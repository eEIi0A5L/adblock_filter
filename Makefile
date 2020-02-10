test:
	./scripts/fmt.sh
	./scripts/js.sh
	./scripts/check_merge.sh

maint:
	./scripts/maint.sh

dup:
	./scripts/dup.sh

ast:
	./scripts/ast.sh

domain:
	./scripts/domain.sh

cd:
	./scripts/cd.sh

count:
	./scripts/count.sh
