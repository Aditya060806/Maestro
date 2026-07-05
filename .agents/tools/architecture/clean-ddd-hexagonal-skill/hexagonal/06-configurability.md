<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Configurability

```typescript
// infrastructure/config/container.ts
function configureDevelopment(container: Container): void {
  container.bind<IOrderRepositoryPort>('IOrderRepositoryPort').to(InMemoryOrderRepository);
  container.bind<IEventPublisherPort>('IEventPublisherPort').to(InMemoryEventPublisher);
  container.bind<IPaymentGatewayPort>('IPaymentGatewayPort').to(FakePaymentGateway);
}
function configureProduction(container: Container): void {
  container.bind<IOrderRepositoryPort>('IOrderRepositoryPort').to(PostgresOrderRepository);
  container.bind<IEventPublisherPort>('IEventPublisherPort').to(RabbitMQEventPublisher);
  container.bind<IPaymentGatewayPort>('IPaymentGatewayPort').to(StripePaymentGateway);
}
```
